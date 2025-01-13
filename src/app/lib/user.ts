import { writable } from "svelte/store";

interface IUser {
    id: number;
    name: string;
    roles: string[];
}

const windowUser: IUser = (window as any).user;

if (windowUser) {
    delete (window as any).user;
}

const user = writable<IUser | null>(!windowUser || windowUser.id == null ? null : windowUser);

export default user;