import { ThemeDefinition } from "vuetify";

//Cannot use namespace 'ThemeDefinition' as a type.
type ThemeDefinition = typeof ThemeDefinition;

export const systemTheme : ThemeDefinition = {
    dark: false,
    colors: {
        //background: '#FFFFFF',
        //surface: '#FFFFFF',
        primary : '#423129',
        'primary-lighten-5' : '#ebebeb',
        'primary-lighten-4' : '#cecbca',
        'primary-lighten-3' : '#b1a8a3',
        'primary-lighten-2' : '#94857c',
        'primary-lighten-1' : '#7f6b5e',
        'primary-darken-1' : '#6b5242',
        'primary-darken-2' : '#5f493b',
        'primary-darken-3' : '#503d32',
        'primary-darken-4' : '#33241e',
        secondary : '#c66210',
        'secondary-lighten-5' : '#faf3e2',
        'secondary-lighten-4' : '#f4e1b6',
        'secondary-lighten-3' : '#edcd88',
        'secondary-lighten-2' : '#e7ba59',
        'secondary-lighten-1' : '#e4ab39',
        'secondary-darken-1' : '#e19e25',
        'secondary-darken-2' : '#dd9320',
        'secondary-darken-3' : '#d7851a',
        'secondary-darken-4' : '#d17715',
        // error: '#B00020',
        // info: '#2196F3',
        // success: '#4CAF50',
        // warning: '#FB8C00',
    },
}