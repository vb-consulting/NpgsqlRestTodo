import { addError } from "$lib/toastStore";
import user from "$lib/user";

export default async function api<TResponse>(
    func: () => Promise<{status: number, response: TResponse}>,
    failedMessage: string = "Failed to fetch data",
    onfail: (status: number | unknown) => boolean | void = () => false,
    okStatuses: number[] = [200, 204],
    throwErrors: boolean = true
) : Promise<TResponse> {
    try {
        const { status, response } = await func();
        if (status === 401) {
            user.update(() => null);
        }
        else if (okStatuses.indexOf(status) == -1) {
            if (!onfail(status)) {
                let msg = `${failedMessage}: ${status}${response ? " - " + response : ""}`;
                addError(msg);
                if (throwErrors) {
                    throw new Error(msg);
                }
            }
        }
        return response;
    } catch (e) {
        let msg = `${failedMessage}: ${e}`;
        console.error(msg);
        if (!onfail(0)) {
            addError(msg);
            if (throwErrors) {
                throw new Error(msg);
            }
        }
        return undefined as TResponse;
    }
}
