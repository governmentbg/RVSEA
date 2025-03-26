export interface IButton {
    name?: String,
    icon?: String,
    title?: String,
    to?: String,
    clickHandler?: Function,
    visible?: boolean | Function,
    enabled?: boolean | Function,
}