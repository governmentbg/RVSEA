<template>
    <v-dialog v-model="showDialog" scrollable @click:outside="clickOutsideHandler" @contextmenu.prevent>
        <v-toolbar color="transparent" density="compact">
            <v-spacer></v-spacer>
            <v-toolbar-items>
                <v-btn icon color="white" @click="showDialog = false">
                    <v-icon>mdi-close</v-icon>
                </v-btn>
            </v-toolbar-items>
        </v-toolbar>
        <v-container class="d-flex align-center justify-center">
            <v-img :src="src" :lazy-src="src" max-height="80vh" @contextmenu.prevent>
                <template v-slot:placeholder>
                    <div class="d-flex align-center justify-center fill-height">
                        <v-progress-circular color="grey-lighten-4" indeterminate></v-progress-circular>
                    </div>
                </template>
            </v-img>
        </v-container>
    </v-dialog>
    <!-- <v-dialog @click="disableContextmenu" v-model="dialogIsVisible" persistent>
        <button class="close-button topright" @click="dialogIsVisible = false">X</button>
        <img :src="src" />
    </v-dialog> -->
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue';
export default defineComponent({
    name: 'DisplayImageModal',
    components: {},
    props: {
        modelValue: {
            type: Boolean,
            default: false,
        },
        src: {
            type: String,
        },
    },
    emits: ['update:modelValue', 'close'],
    setup(props, context) {
        const showDialog = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        const clickOutsideHandler = () => {
            console.log('clickOutsideHandler');
            showDialog.value = false;
            context.emit('close');
        };

        const disableContextmenu = () => {
            window.addEventListener('contextmenu', (e: Event) => {
                e.preventDefault();
            });
        };

        return {
            disableContextmenu,
            clickOutsideHandler,
            showDialog,
        };
    },
});
</script>

<style scoped lang="scss">
// @import '@/assets/styles/display-create-edit.scss';
// @import '@/assets/styles/dialog.scss';

// .vw-50 {
//     width: 90vw;
//     min-height: 100vh;
// }
// .close-button {
//     border: none;
//     display: inline-block;
//     padding: 8px 16px;
//     vertical-align: middle;
//     overflow: hidden;
//     text-decoration: none;
//     color: inherit;
//     background-color: white;
//     text-align: center;
//     cursor: pointer;
//     white-space: nowrap;
// }
// .topright {
//     position: absolute;
//     right: 0;
//     top: 0;
// }
// :deep(.v-card-title),
// :deep(h3) {
//     box-shadow: none !important;
// }
</style>
