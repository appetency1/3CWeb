import { http } from '@/utils/request'

export interface AiMessage {
  role: 'user' | 'assistant'
  content: string
}

export const aiApi = {
  chat: (messages: AiMessage[]) =>
    http<{ reply: string }>('/public/ai/chat', { messages }, { method: 'POST' }),
}
