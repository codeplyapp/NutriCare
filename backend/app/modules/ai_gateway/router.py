from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.core.database import get_db
from app.modules.user_profile.router import get_current_user_id
from app.modules.ai_gateway.schemas import ChatMessageRequest, ChatMessageResponse, ChatHistoryResponse, ChatHistoryItem
from app.modules.ai_gateway.service import AIGatewayService

router = APIRouter(prefix="/nutri-mate", tags=["Nutri Mate AI Gateway"])

@router.post("/chat", response_model=ChatMessageResponse)
def send_chat_message(
    req: ChatMessageRequest,
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    return AIGatewayService.generate_nutri_mate_reply(db, current_user_id, req.message)

@router.get("/history", response_model=ChatHistoryResponse)
def get_chat_history(
    current_user_id: str = Depends(get_current_user_id),
    db: Session = Depends(get_db)
):
    msgs = AIGatewayService.get_history(db, current_user_id)
    return ChatHistoryResponse(
        messages=[
            ChatHistoryItem(
                id=m.id,
                sender=m.sender,
                message=m.message,
                is_escalated=m.is_escalated,
                sent_at=m.sent_at
            )
            for m in msgs
        ]
    )
