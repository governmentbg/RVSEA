<template>
    <v-dialog
        oncontextmenu="return false;"
        v-model="showDialog"
        scrollable
        @click:outside="clickOutsideHandler"
        @contextmenu.prevent
    >
        <div class="wrapper" id="windows">
            <object :data="src" type="application/pdf" tabindex="-1"></object>
            <div
                v-if="packageType !== 'A' && digitalObjectType != DigitalObjectType.MasterFile && digitalObjectType != DigitalObjectType.DerivativeFile"
                :class="classes"
            ></div>
        </div>
    </v-dialog>
</template>

<script lang="ts">
import { computed, defineComponent } from 'vue';
import { DigitalObjectType } from '@/enums/digitalObject';
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
        },
        packageType: {
            type: String,
            required: false,
        },
        disableScroll: {
            type: Boolean,
            default: true
        }
    },
    emits: ['update:modelValue', 'close'],
    setup(props, context) {
        const showDialog = computed({
            get: () => props.modelValue,
            set: (value) => context.emit('update:modelValue', value),
        });
        const windows = document.getElementById('windows');
        const clickOutsideHandler = () => {
            console.log('clickOutsideHandler');
            showDialog.value = false;
            context.emit('close');
        };

        const classes = props.disableScroll ? "embed-cover" : "";

        const disableContextmenu = () => {
            window.addEventListener('contextmenu', (e: Event) => {
                e.preventDefault();
            });
        };

        return {
            disableContextmenu,
            windows,
            clickOutsideHandler,
            DigitalObjectType,
            classes,
            showDialog,
        };
    },
});
</script>

<style scoped lang="scss">
object {
    margin: auto !important;
    min-width: 90vh !important;
    min-height: 90vh !important;
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
