import { AnnouncementModel } from '../../model/AnnouncementModel';
import { TransportationService } from '../../service/TransportationService';

@Observed
export class AnnouncementsViewModel {
  public announcements: AnnouncementModel[] = [];
  public isLoading: boolean = false;

  async loadNews() {
    this.isLoading = true;
    try {
      this.announcements = await TransportationService.getInstance().getNews();
    } catch (error) {
      console.error('Failed to load news', error);
    } finally {
      this.isLoading = false;
    }
  }
}