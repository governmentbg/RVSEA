<template>
    <editor
        api-key="no-api-key"
        :init="init"
    />
</template>

<script lang="ts">

import { defineComponent } from 'vue';
import Editor from '@tinymce/tinymce-vue';

export default defineComponent({
    components: { Editor },
    props: {
        readOnly: {
            type: Boolean,
            default: false,
        },
        language: {
            type: String,
            default: 'bg_BG'
        }
    },
    setup(props) {
        // eslint-disable-next-line @typescript-eslint/no-explicit-any
        const example_image_upload_handler = (blobInfo: any) => new Promise((resolve, reject) => {
            try {
                const base64str = `data:${blobInfo.blob().type};base64,${blobInfo.base64()}`;
                resolve(base64str);
            } catch (error) {
                reject(error);
            }
        });

        const init = {
            menubar: true,
            readonly: 1,
            language: props.language,
            promotion: false,
            image_advtab: true,
            toolbar_mode: 'sliding',
            images_upload_handler: example_image_upload_handler,
            plugins: 'preview importcss searchreplace autolink autosave save directionality code visualblocks visualchars fullscreen image link media codesample table charmap pagebreak nonbreaking anchor insertdatetime advlist lists wordcount help charmap quickbars emoticons accordion',
            toolbar: "undo redo | accordion accordionremove | blocks fontfamily fontsize | bold italic underline strikethrough | align numlist bullist | link image | table media | lineheight outdent indent| forecolor backcolor removeformat | charmap emoticons | code fullscreen preview | save print | pagebreak anchor codesample | ltr rtl",
        };
        return {
            init
        };
    },
});
</script>

<style>
.tox-tinymce-aux {display: none !important;}
</style>
