import relationalStore from '@ohos.data.relationalStore';
import { common } from '@kit.AbilityKit';

type RdbValue = string | number | boolean | null;
type Model = Record<string, RdbValue>;

export class RelationalStorageManager {
  private static instance: RelationalStorageManager;
  private rdbStore?: relationalStore.RdbStore;

  private constructor() {
  }

  static getInstance(): RelationalStorageManager {
    if (!RelationalStorageManager.instance) {
      RelationalStorageManager.instance = new RelationalStorageManager();
    }
    return RelationalStorageManager.instance;
  }

  async init(context: common.UIAbilityContext, dbName: string): Promise<void> {
    if (this.rdbStore) {
      return;
    }

    this.rdbStore = await relationalStore.getRdbStore(context, {
      name: dbName,
      securityLevel: relationalStore.SecurityLevel.S1
    });
  }

  // -----------------------
  // CREATE TABLE (AUTO)
  // -----------------------
  async ensureTable<T extends Model>(modelName: string, model: T): Promise<void> {
    const columns: string[] = [];

    Object.keys(model).forEach((key: string) => {
      if (key === 'id') {
        columns.push('id INTEGER PRIMARY KEY AUTOINCREMENT');
      } else {
        columns.push(`${key} TEXT`);
      }
    });

    const sql = `
      CREATE TABLE IF NOT EXISTS ${modelName} (
        ${columns.join(',')}
      )
    `;

    await this.rdbStore!.executeSql(sql);
  }

  // -----------------------
  // INSERT OR UPDATE
  // -----------------------

  async save<T extends Model>(modelName: string, data: T): Promise<number> {
    await this.ensureTable(modelName, data);

    const valuesBucket: Record<string, relationalStore.ValueType> = {};
    const keys = Object.keys(data);
    for (const key of keys) {
      if (key !== 'id' && data[key] !== undefined) {
        valuesBucket[key] = data[key] as relationalStore.ValueType;
      }
    }

    // INSERT
    const result = await this.rdbStore!.insert(modelName, valuesBucket);
    return result;
  }

  // -----------------------
  // FIND ALL
  // -----------------------
  async findAll<T extends Model>(modelName: string): Promise<T[]> {
    const predicates = new relationalStore.RdbPredicates(modelName);
    const resultSet = await this.rdbStore!.query(predicates);

    const results: T[] = [];

    while (resultSet.goToNextRow()) {
      const row: Model = {};
      for (let i = 0; i < resultSet.columnCount; i++) {
        const name = resultSet.getColumnName(i);
        row[name] = resultSet.getString(i);
      }
      results.push(row as T);
    }

    resultSet.close();
    return results;
  }

  // -----------------------
  // DELETE BY ID
  // -----------------------
  async delete<T extends Model>(modelName: string, model: T): Promise<void> {

    const predicates = new relationalStore.RdbPredicates(modelName);
    predicates.equalTo('flightNumber', model.flightNumber);

    await this.rdbStore!.delete(predicates);
  }

  async findFlightById<T extends Model>(modelName: string, flightId: string, template: T): Promise<T | undefined> {
    const predicates = new relationalStore.RdbPredicates(modelName);
    predicates.equalTo('flightId', flightId);

    try {
      // 2. Execute the query
      const resultSet = await this.rdbStore!.query(predicates);

      // 3. Move to the first record (Find By ID expects 1 or 0 results)
      if (resultSet.goToFirstRow()) {
        const result = await this._mapRowToFlight<T>(resultSet, template);
        resultSet.close(); // Important: Close to release memory
        return result;
      }

      resultSet.close();
      return undefined; // Not found
    } catch (error) {
      console.error(`[DB_ERROR] Failed to find flight by ID: ${flightId}`, error);
      return undefined;
    }
  }

  private async _mapRowToFlight<T extends Model>(resultSet: relationalStore.ResultSet, template: T): Promise<T> {

    const obj: Record<string, string | number | boolean | null> = {};

    const keys = Object.keys(template as object);

    for (const key of keys) {
      const columnIndex = resultSet.getColumnIndex(key);

      // If column is missing in DB, fallback to template value
      if (columnIndex === -1) {
        const templateRecord = template as Record<string, string | number | boolean | null>;
        obj[key] = templateRecord[key];
        continue;
      }

      // Identify type from template to choose the correct ResultSet method
      const templateValue = (template as Record<string, Object>)[key];

      if (typeof templateValue === 'number') {
        obj[key] = resultSet.getDouble(columnIndex);
      } else if (typeof templateValue === 'boolean') {
        // In SQLite/RDB, booleans are stored as 1 (true) or 0 (false)
        obj[key] = resultSet.getLong(columnIndex) === 1;
      } else {
        // Default to string for other types
        obj[key] = resultSet.getString(columnIndex);
      }
    }

    // Use 'as T' for the final explicit cast to satisfy ArkTSCheck
    return obj as T;

  }
}

