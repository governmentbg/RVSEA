import moment from 'moment';

const capitalize = (str) => {
    str = typeof str === 'function' ? str() : str;
    return str.charAt(0).toUpperCase() + str.slice(1);
};

const date = (value) => {
    if (value) {
        return moment(String(value)).format('DD.MM.YYYY');
    }
};

const datetime = (value) => {
    if (value) {
        return moment(String(value)).format('DD.MM.YYYY HH:mm');
    }
};

const time = (value) => {
    if (value) {
        return moment(String(value)).format('HH:mm');
    }
};

export default {
    capitalize,
    date,
    datetime,
    time
}