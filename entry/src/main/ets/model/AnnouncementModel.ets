export interface AnnouncementRoot {
  help?: string;
  success?: boolean;
  result?: AnnouncementResult;
}

export interface AnnouncementResult {
  includeTotal?: boolean;
  resourceId?: string;
  fields?: AnnouncementField[];
  recordsFormat?: string;
  records: AnnouncementRecords[];
  limit?: number;
  _links?: AnnouncementLinks;
  total?: number;
}

export interface AnnouncementRecords {
  id?: number;
  routeNumber?: number;
  title: string;
  startDate: string;
  endDate: string;
}

interface GeneratedTypeLiteralInterface_1 {
  notes?: string;
  typeOverride?: string;
  label?: string;
}

export interface AnnouncementField {
  type?: string;
  id?: string;
  info?: GeneratedTypeLiteralInterface_1;
}

export interface AnnouncementLinks {
  start?: string;
  next?: string;
}

// Model used within the App/ViewModel
export interface AnnouncementModel {
  title: string;
  startDate: string;
  endDate: string;
}