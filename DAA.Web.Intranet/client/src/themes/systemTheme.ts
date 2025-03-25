import { ThemeDefinition } from "vuetify";
import { VBtn, VCard } from "vuetify/lib/components";
//Cannot use namespace 'ThemeDefinition' as a type.
type ThemeDefinition = typeof ThemeDefinition;

export const systemTheme : ThemeDefinition = {
    dark: false,
    colors: {
        // background: '#FFFFFF',
        // surface: '#FFFFFF',
        // "surface-variant": "#424242",
        // "on-surface-variant": "#EEEEEE",
        primary : '#00B300',
        'primary-lighten-5' : '#E6F6E4',
        'primary-lighten-4' : '#C3E8BD',
        'primary-lighten-3' : '#9AD992',
        'primary-lighten-2' : '#6DCB63',
        'primary-lighten-1' : '#46BF3E',
        'primary-darken-1' : '#00A400',
        'primary-darken-2' : '#009200',
        'primary-darken-3' : '#008100',
        'primary-darken-4' : '#006200',
        secondary : '#CCFFCC',
        'secondary-lighten-5' : '#EAFFEA',
        'secondary-lighten-4' : '#B1FEB2',
        'secondary-lighten-3' : '#98FB99',
        'secondary-lighten-2' : '#84F584',
        'secondary-lighten-1' : '#72F06E',
        'secondary-darken-1' : '#66DF63',
        'secondary-darken-2' : '#59CA56',
        'secondary-darken-3' : '#4EB84C',
        'secondary-darken-4' : '#3A9638',
        // error: '#B00020',
        // info: '#2196F3',
        // success: '#4CAF50',
        // warning: '#FB8C00',
    },
};


export const componentAliases = {
    SubmitBtn : VBtn,
    DialogBtn: VBtn,
    CancelBtn : VBtn,
    BackBtn : VBtn,
    SearchCard: VCard,
}

export const systemDefaults = {
    VBtn: {
        color: 'primary',
    },
    SubmitBtn: {
        color : 'primary',
    },
    DialogBtn: {
        color : 'primary',
        variant: 'elevated',
    },
    CancelBtn: {
        color: 'secondary',
    },
    BackBtn: {
        color: 'secondary',
    },
    VExpansionPanelTitle : {
        color: 'secondary',
    },
    SearchCard: {
        color: 'secondary-lighten-5',
    }
};