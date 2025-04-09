interface IUser {
    name: string;
    roles: string[];
}

type StatusArg<T> = {id: T, position: "left" | "right", index: number};