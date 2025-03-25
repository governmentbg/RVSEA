export interface IDropdownItem {
	id: number | string;
	text: string,
	to?: string // this is used when the dropdown item is a link
}