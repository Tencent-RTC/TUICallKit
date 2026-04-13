import axios from 'axios';

const http = axios.create({
  baseURL: 'http://localhost:3000',
  timeout: 10000,
});

interface StartTranscriptionParams {
  SdkAppId: number;
  RoomId: string;
  RoomIdType? : number;
  UserId: string;
  UserSig: string;
}

interface StopTranscriptionParams{
  TaskId: string;
  [key: string]: string;
}

export function startAITranscription(params: StartTranscriptionParams) {
  return http.post('/start', params);
}

export function stopAITranscription(params: StopTranscriptionParams) {
  return http.post('/stop', params);
}

