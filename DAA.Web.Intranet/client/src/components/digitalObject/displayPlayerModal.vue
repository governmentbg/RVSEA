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
        <div class="videoContainer mx-auto" >
            <video controls autoplay loop controlslist="nodownload" playsinline disablepictureinpicture :src="src"></video>
        </div>
    </v-dialog>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue';
export default defineComponent({
    name: 'DisplayPlayerModal',
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

        const showDialog = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });

        return {
            disableContextmenu,
            clickOutsideHandler,
            showDialog,
        };
    },
});
</script>
<style scoped>
 .videoContainer {
    width: 85vw;
    height: 85vh;
    align-content: center;
    text-align: center;
 }


.videoContainer video {
    margin-left: auto;
    margin-right: auto;
    object-position: 50% 50%;
    object-fit: scale-down;
    height: 85%;
}

</style>
