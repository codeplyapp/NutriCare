import logging
from datetime import datetime
from app.modules.notification.schemas import NotificationSendRequest, NotificationSendResponse

logger = logging.getLogger(__name__)

class NotificationService:
    @staticmethod
    def dispatch_notification(req: NotificationSendRequest) -> NotificationSendResponse:
        """
        Orkestrasi pengiriman notifikasi push ke aplikasi via FCM dan relay ke jam tangan pintar.
        """
        logger.info(f"[NOTIF DISPATCH] Target: {req.target} | User: {req.user_id} | Title: {req.title} | Body: {req.body}")
        
        # Di tahap produksi, ini mengintegrasikan Firebase Admin SDK messaging.send()
        return NotificationSendResponse(
            status="delivered",
            delivered_to=req.target,
            timestamp=datetime.utcnow()
        )
