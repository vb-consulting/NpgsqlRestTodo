import { writable } from "svelte/store";

const windowUser: IUser = (window as any).user;
if (windowUser) {
    delete (window as any).user;
}
const user = writable<IUser | null>(!windowUser || windowUser.name == null ? null : windowUser);
export default user;