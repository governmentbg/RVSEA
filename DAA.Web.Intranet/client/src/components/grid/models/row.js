class Row {
    constructor(items, props) {
        this.defaults = {
            selected: false,
            index: 0,
        }
        
        this.prop = {
            ...this.defaults.prop,
            ...props
        };
        this.items = items;
    }

    
}

export default Row;