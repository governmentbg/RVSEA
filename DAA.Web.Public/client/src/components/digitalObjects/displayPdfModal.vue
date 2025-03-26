<template>
    <v-dialog
        oncontextmenu="return false;"
        v-model="showDialog"
        scrollable
        @click:outside="clickOutsideHandler"
        @contextmenu.prevent
    >
        <div class="wrapper">
            <object tabindex="-1" :data="src"></object>
            <div
                v-if="digitalObjectType != -1 && packageType !== 'A' && digitalObjectType != DigitalObjectType.MasterFile"
                class="embed-cover"
            ></div>
        </div>
    </v-dialog>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue';
import { DigitalObjectType } from '@/enums/digitalObjects';
export default defineComponent({
    name: 'DisplayPdfModal',
    components: {},
    props: {
        modelValue: {
            type: Boolean,
            default: false,
        },
        src: {
            type: String,
        },
        digitalObjectType: {
            type: Number,
            default: -1
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
            DigitalObjectType
        };
    },
});
</script>

<style scoped lang="scss">
object {
    margin: auto !important;
    min-width: 100vh !important;
    min-height: 100vh !important;
}
.embed-cover {
    position: absolute;
    top: 0;
    left: 0;
    bottom: 0;
    right: 0;
    background-color: transparent;
}
.wrapper {
    margin: auto;
    overflow: hidden;
}
</style>
