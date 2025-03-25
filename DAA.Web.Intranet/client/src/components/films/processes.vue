<template>
    <v-row class="mt-3">
        <v-col class="d-flex justify-content-center">
            <v-btn @click="startProcess(cardsProcess)" v-if="canStartCardsProcess" :disabled="isBusy">{{
                t('films.buttons.cardsProcess')
            }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('films.buttons.cardsProcess')}}
                </v-tooltip>
            </v-btn>
            <v-divider vertical v-if="canStartEditProcess"></v-divider>
            <v-btn @click="startProcess(editProcess)" v-if="canStartEditProcess" :disabled="isBusy">{{
                t('films.buttons.editProcess')
            }}
                <v-tooltip
                    activator="parent"
                    location="bottom"
                >
                {{t('films.buttons.editProcessTooltip')}}
                </v-tooltip>
            </v-btn>
        </v-col>
    </v-row>
</template>

<script lang="ts">
import { defineComponent, computed, PropType, inject, Ref, ref } from 'vue'
import { useI18n } from 'vue-i18n'
import { Film } from '@/models/film'
import { ProcessType } from '@/enums/process'
import filmService from '@/services/film.service'
import { IMessage } from '@/interfaces/notification'
import { Message } from '@/models/notification'
import { ResponseResult } from '@/models/responseResult'
import { ProcessModel } from '@/models/process'
import { RoleNames } from '@/enums/roles'
import { useStore } from '@/store/user'
import { useRouter } from 'vue-router'
import { useRedirectWithId } from '@/helpers/router.helper'

export default defineComponent({
    name: 'FilmProcesses',
    emits: ['refresh'],
    props: {
        filmData: {
            type: Object as PropType<Film>,
            required: true,
        },
    },
    setup(props, context) {
        const { t } = useI18n()
        const model = computed(() => props.filmData)
        const message = inject('notificationMessage') as Ref<IMessage>
        const userStore = useStore()

        const hasGroupI = computed(() => userStore.getters.hasRole(RoleNames.GroupI))

        const editProcess = ProcessType.FilmEditData
        const cardsProcess = ProcessType.FilmRegisterCard
        const isBusy = ref(false);

        const router = useRouter();
        const goEdit = () => {
            useRedirectWithId(router, 'EditFilm', model.value.systemIdentifier || '');
        }

        const startProcess = async (process: ProcessType) => {
            isBusy.value = true;
            try {
                const processModel = new ProcessModel()
                processModel.processTypeId = process
                processModel.archiveId = model.value.archiveId || 0
                processModel.filmSystemIdentifier = model.value.systemIdentifier || ''

                await filmService.startProcess(processModel)
                isBusy.value = false;

                if(process == ProcessType.FilmEditData){
                    goEdit();
                }
                else {
                    context.emit('refresh')
                }
            } catch (error: unknown) {
                isBusy.value = false;
                const errorResult  = error as ResponseResult;
                message.value = new Message({
                  text:  errorResult.showMessage ? errorResult.message : t('error.basic'),
                  display: true,
                });
            }
        }

        const canStartEditProcess = computed(
            () => hasGroupI.value == true && (!model.value.currentProcessId || model.value.currentProcessId == 0)
        )
        const canStartCardsProcess = computed(
            () => hasGroupI.value == true && (!model.value.currentProcessId || model.value.currentProcessId == 0) && model.value.hasCompletedCardsProcess == false // and completed approved RegisterData process
        )

        return {
            t,
            model,
            editProcess,
            cardsProcess,
            startProcess,
            canStartEditProcess,
            canStartCardsProcess,
            isBusy,
        }
    },
})
</script>
