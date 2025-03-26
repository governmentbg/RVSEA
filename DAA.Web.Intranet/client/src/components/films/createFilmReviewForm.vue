<template>
    <!-- <v-card class="w-100"> -->
    <v-card-title class="v-card-title-uppercase">{{
        t('filmReviews.index.grid.cols.accessCreationForm')
    }}</v-card-title>
    <v-container>
        <!-- <v-expansion-panels v-model="panel" multiple>
            <v-expansion-panel value="general">
                <v-expansion-panel-text> -->
        <Form @submit="submit">
            <v-row>
                <v-col class="col-12">
                    <label class="required" for="fReaderProfiles">{{
                        t('filmReviews.index.grid.cols.readerProfile')
                    }}</label>
                    <Dropdown
                        name="fReaderProfiles"
                        required="required"
                        v-model="filmReviewData.userId"
                        :label="t('filmReviews.index.grid.cols.readerProfile')"
                        labelProp="label"
                        valueProp="code"
                        :multiselect="false"
                        :items="readerProfiles"
                    />
                </v-col>
            </v-row>
            <!-- <label>{{ t('filmReviews.index.grid.cols.readerName') }}</label> -->
            <v-row class="mt-3">
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldFirstName"
                        :label="t('filmReviews.index.grid.cols.firstName')"
                        v-model="filmReviewData.firstName"
                        validation="required"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldSurname"
                        :label="t('filmReviews.index.grid.cols.surname')"
                        v-model="filmReviewData.surname"
                    />
                </v-col>
                <v-col class="col-12 col-lg-4">
                    <text-field
                        name="fldLastName"
                        :label="t('filmReviews.index.grid.cols.lastName')"
                        v-model="filmReviewData.lastName"
                        validation="required"
                    />
                </v-col>
            </v-row>

            <v-row>
                <v-col class="col-12">
                    <!-- <label class="required" for="fFilms">{{ t('filmReviews.index.grid.cols.filmSystemIdentifier') }}</label>
                <Dropdown
                    name="fFilms"
                    v-model="filmReviewData.filmSystemIdentifier"
                    :label="t('funds.columns.industryType')"
                    labelProp="label"
                    valueProp="code"
                    :multiselect="false"
                    :items="films"
                    :searchable="true"
                    required="required"
                /> -->
                    <div :class="fieldSpacing">
                        <label class="required" for="fFilms">{{ t('filmReviews.index.grid.cols.filmSystemIdentifier') }}</label>
                        <Dropdown
                            name="fFilms"
                            required="required"
                            :items="films"
                            v-model="filmReviewData.filmSystemIdentifier"
                            ref="filmsDropdown"
                            :multiselect="false"
                            :label="t('filmReviews.index.grid.cols.filmSystemIdentifier')"
                        />
                    </div>
                </v-col>
            </v-row>
                <v-row class="mt-3">
                <v-col class="d-flex justify-content-center" style="margin-top: 100px">
                    <v-btn type="submit" class="mr-4">{{
                        t('filmReviews.index.grid.cols.accessCreate')
                    }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('filmReviews.index.grid.btn.createTooltip')}}
                        </v-tooltip>
                    </v-btn>
                    <v-btn class="clear bg-secondary" @click="goBack">{{
                        t('common.cancel')
                    }}
                        <v-tooltip
                            activator="parent"
                            location="bottom"
                        >
                        {{t('filmReviews.index.grid.btn.cancelTooltip')}}
                        </v-tooltip>
                    </v-btn>
                </v-col>
            </v-row>
        </Form>
        <!-- </v-expansion-panel-text>
            </v-expansion-panel>
        </v-expansion-panels> -->
    </v-container>
    <!-- </v-card> -->
</template>

<script lang="ts">
import { defineComponent, PropType, ref, onMounted, watch } from 'vue';
import { useI18n } from 'vue-i18n';
import { IFilmReview } from '@/interfaces/film';
import { IDropdownOption } from '@/interfaces/dropdown';
// import { NomenclatureCode } from '@/enums/nomenclature';
import dropdownService from '@/services/dropdown.service';
import TextField from '@/components/field/text.field.vue';
//import TextAreaField from '@/components/field/textarea.field.vue';
// import Switch from '@/components/checkbox/switch.vue';
import Dropdown from '@/components/dropdown/dropdown.vue';
import { Form } from 'vee-validate';
import { useRedirect } from '@/helpers/router.helper';
import router from '@/router';

export default defineComponent({
    name: 'CreateRilmReviewForm',
    components: {
        Dropdown,
        TextField,
        //TextAreaField,
        Form
    },
    props: {
        modelValue: {
            type: Object as PropType<IFilmReview>,
            required: true,
        },
    },
    emits: ['update:modelValue', 'change', 'submit'],
    setup(props, { emit }) {
        const filmReviewData = ref(props.modelValue);
        const { t } = useI18n();
        const panel = ref(['general']);

        const readerProfiles = ref<IDropdownOption[]>([]);
        const getReaderProfiles = () => {
            dropdownService.getReaderProfiles().then((data) => (readerProfiles.value = data));
        };

        const filmsDropdown = ref();
        const films = ref<IDropdownOption[]>([]);
        const getFilms = () => {
            dropdownService.getAllFilms().then((data) => (films.value = data));
        };
        const submit = () => {
            emit('submit');
        }
        const goBack = () => {
            useRedirect(router, 'DisplayFilmReviews');
        };

        onMounted(() => {
            getReaderProfiles();
            getFilms();
        });

        watch(
            () => filmReviewData,
            () => {
                emit('update:modelValue', filmReviewData.value);
                emit('change', filmReviewData.value);
            }
        );

        return {
            t,
            panel,
            filmReviewData,
            readerProfiles,
            films,
            filmsDropdown,
            submit,
            goBack,
        };
    },
});
</script>

<style lang="scss" scoped>
@import '@/assets/styles/display-create-edit.scss';
</style>
