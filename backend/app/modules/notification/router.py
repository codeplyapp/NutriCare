from fastapi import APIRouter
from app.modules.notification.schemas import NotificationSendRequest, NotificationSendResponse
from app.modules.notification.service import NotificationService

router = APIRouter(prefix="/notifications", tags=["Notification Service"])

@router.post("/send", response_model=NotificationSendResponse)
def send_notification(req: NotificationSendRequest):
    return NotificationService.dispatch_notification(req)
