// autogenerated at 2025-03-21T11:41:44.4920520+00:00
interface IAuthLoginRequest {
    username: string | null;
    password: string | null;
    data?: string | null;
    ipAddress?: string | null;
}

interface IAuthRegisterRequest {
    email: string | null;
    password: string | null;
    repeat: string | null;
}

interface IAuthRegisterResponse {
    code: number | null;
    message: string | null;
}

