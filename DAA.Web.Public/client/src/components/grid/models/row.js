class Row {
    constructor(items, props) {
        this.prop = {
            ...this.defaults.prop,
            ...props
        };
        this.items = items;
    }

    defaults = {
        selected: false,
        index: 0,
    }
}

export default Row;