// autogenerated at 2025-04-04T11:23:29.3559523+00:00
interface IAuthConfirmEmailCodeRequest {
    code: string | null;
    email: string | null;
    analyticsData?: string | null;
    ipAddress?: string | null;
}

interface IAuthLoginRequest {
    username: string | null;
    password: string | null;
    analyticsData?: string | null;
    ipAddress?: string | null;
}

interface IAuthRegisterRequest {
    email: string | null;
    password: string | null;
    repeat: string | null;
    analyticsData?: string | null;
    ipAddress?: string | null;
}

interface IAuthRegisterResponse {
    code: number | null;
    message: string | null;
}

