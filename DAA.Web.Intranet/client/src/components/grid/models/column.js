class Column {
    constructor(props) {
        this.defaults = {
            type: 'text',
            sortable: false,
            filterable: false,
            textAlign: 'center',
            cellClass: '',
            titleClass: '',
            visible: true,
        }

        this.prop = props.prop || this.defaults.prop;
        this.title = props.title || '';
        this.type = props.type || this.defaults.type;
        this.sortable = props.sortable || this.defaults.sortable;
        this.filterable = props.filterable || this.defaults.filterable;
        this.textAlign = props.textAlign || this.defaults.textAlign;
        this.dateTimeFormat = props.dateTimeFormat || this.defaults.dateTimeFormat;
        this.cellClass = props.cellClass || this.defaults.cellClass;
        this.titleClass = props.titleClass || this.defaults.titleClass;
        this.template = props.template || undefined;
        this.renderFunction = props.renderFunction || undefined;
        this.visible = props.visible || this.defaults.visible;
    }

    
}

export default Column;