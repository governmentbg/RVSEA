<template>
    <top-navigation class="d-print-none" @navIconClick="sideNav = !sideNav" />
		<ReadingRoomSideNavigation v-model="sideNav" />
		<v-main>
			<v-container fluid>
				<slot />
			</v-container>
		</v-main>

		<!-- <v-footer color="primary" app bottom padless>
			<v-layout class="d-flex align-items-start justify-content-center">
				<picture>
					<source srcset="@/assets/ES.png" />
					<img class="footer" src="@/assets/ES.png" alt="Logo" width="150" height="120" />
				</picture>
				<div id="footertext">
					<p>
						{{ t('footer.footerText') }}
					</p>
					<strong>
						{{ t('footer.version', { version: version }) }}
					</strong>
				</div>
				<picture>
					<source srcset="@/assets/DU.png" />
					<img class="footer" src="@/assets/DU.png" alt="Logo" width="150" height="120" />
				</picture>
			</v-layout>
		</v-footer> -->
        <Footer />
</template>
<script lang="ts">
import { defineComponent, ref, watch } from 'vue';
import { useI18n } from 'vue-i18n';

import TopNavigation from '@/components/navigation/topNav.vue';
import ReadingRoomSideNavigation from '@/components/navigation/readingRoomSideNav.vue';
import Footer from '@/components/layouts/Footer.vue';

export default defineComponent({
    name: "RRRLayout",
    components: {
        TopNavigation,
        ReadingRoomSideNavigation,
        Footer,
    },
    setup() {
        const { t } = useI18n();

        const sideNav = ref(false);

        watch(
            () => sideNav.value,
            (val) => {
                sideNav.value = val;
            }
        );

        return {
            t,
            sideNav,
        }
    }
})
</script>
