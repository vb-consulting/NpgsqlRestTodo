import { addError } from "$lib/toastStore";
import user from "$lib/user";

/*
* This function is used to handle API calls and responses.
* It takes a function that returns a promise, and handles the response based on the status code.
* It will show Error Toasts for any errors that occur during the API call.
*/
export default async function api<TResponse>(
    func: () => Promise<{status: number, response: TResponse}> | Promise<number>,
    failedMessage: string = "Failed to fetch data",
    onfail: (status: number | unknown) => boolean | void = () => false,
    okStatuses: number[] = [200, 204],
    throwErrors: boolean = true
) : Promise<TResponse> {
    try {
        const result = await func();
        let status = 0;
        let response: TResponse | undefined = undefined;
        if (typeof result === "number") {
            status = result;
        } else {
            status = result.status;
            response = result.response;
        }
        if (status === 401) {
            user.update(() => null);
        }
        else if (okStatuses.indexOf(status) == -1) {
            if (!onfail(status)) {
                let msg = `${failedMessage}: ${status}${response ? " - " + response : ""}`;
                if (throwErrors) {
                    throw new Error(msg);
                }
                else { 
                    addError(msg);
                }
            }
        }
        return response as TResponse;
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
