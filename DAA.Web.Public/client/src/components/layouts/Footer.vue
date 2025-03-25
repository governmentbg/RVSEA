<template>
    <v-footer color="primary" app bottom padless>
        <v-layout class="d-flex align-items-start justify-content-center">
            <picture style="margin-top: 15px">
                <source srcset="@/assets/ES.jpg" />
                <img class="footer" alt="ESLogo" width="104.6" height="100" />
            </picture>
            <div id="footertext">
                <p>
                    {{ t('footer.footerText') }}
                </p>
                <strong>
                    {{ t('footer.version', { version: version }) }}
                </strong>
            </div>
            <picture style="margin-top: 15px">
                <source srcset="@/assets/DU.jpg" />
                <img class="footer" alt="DULogo" width="130.54" height="100" />
            </picture>
        </v-layout>
    </v-footer>
</template>
<script lang="ts">
import { defineComponent, onMounted, ref } from 'vue';
import { useI18n } from 'vue-i18n';

import settingsService from '@/services/settings.service';

export default defineComponent({
    name: "Footer",
    setup() {
        const { t } = useI18n();
        
        const version = ref('');
        
        const getVersion = async () => {
            try {
                const result = await settingsService.getVersion();
                version.value = result as string;
            } catch (error) {
                console.log(error);
            }
        };

        onMounted(async () => {
            await getVersion();
        });

        return {
            t,
            version,
        }
    },
})
</script>
