<template>
    <v-container>
        <v-row class="col-12 d-print-none">
            <v-col class="d-print-none" cols="6">
                <v-menu class="d-print-none">
                    <template v-slot:activator="{ props }">
                        <v-btn v-bind="props">{{ t('common.exportTo') }}</v-btn>
                    </template>
                    <v-list>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="exportHTMLtoWord"
                                >{{ t('common.exportToWord') }}
                            </v-list-item-title>
                        </v-list-item>
                        <v-list-item class="col-12 cursor">
                            <v-list-item-title class="d-print-none button" @click="printButton"
                                >{{ t('common.exportToPdf') }}
                            </v-list-item-title></v-list-item
                        >
                    </v-list>
                </v-menu>
            </v-col>
            <v-col>
                <back-btn class="d-print-none" style="float: right" @click="goBack"
                    >{{ t('common.back') }}
                    <v-tooltip activator="parent" location="bottom">
                        {{ t('common.back') }}
                    </v-tooltip>
                </back-btn>
            </v-col>
        </v-row>
        <div class="myDiv" id="myProtocol">
            <div class="offset-1">
                <b
                    ><p style="font-family: 'Times New Roman'">
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;ПРЕПИС-ИЗВЛЕЧЕНИЕ
                    </p></b
                >
            </div>
            <br />
            <h4 style="font-family: 'Times New Roman'; text-align: center">П Р О Т О К О Л</h4>
            <h4 style="font-family: 'Times New Roman'; text-align: center">{{ `№ ${model.protocolNumber}` }}</h4>
            <br />
            <p style="font-family: 'Times New Roman'; line-height: 1.5; text-indent: 45px; text-align: justify">
                {{
                    ` Днес, ${formatDate(model.currentDate)}г., се проведе заседание на Експертно-проверочната комисия`
                }}
                {{ `${model.sessionTypeName} на дирекция „${model.archiveName}, назначена със Заповед` }}
                {{
                    ` №:......../${formatDate(model.currentDate)}г. на директора на ${model.archiveName}, в
        състав: `
                }}
            </p>
            <p style="font-family: 'Times New Roman'; margin-bottom: 0px">
                <b>ПРЕДСЕДАТЕЛ:</b>{{ ` ${model.assignedToChairmanName}` }}<br />
                <b>СЕКРЕТАР:</b>{{ ` ${model.assignedToSecretarName}` }}<br />
                <b style="position: absolute">ЧЛЕНОВЕ:</b>
                <span v-for="(item, index) in model.members" :key="item.id">
                    <span v-if="index > 0">
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span
                    >
                    <span v-else class="offset"></span>
                    {{ index + 1 }} {{ item }}<br />
                </span>
            </p>
            <p id="paragraph3" style="font-family: 'Times New Roman'">
                <strong style="font-family: 'Times New Roman'"
                    >Заседанието има кворум и може да взема решения.. За неговото протичане<br />бе приет следният
                    дневен ред:</strong
                >
            </p>
            <br />
            <h5 style="font-family: 'Times New Roman'; text-align: center" id="agenda-title">Д Н Е В Е Н Р Е Д:</h5>
            <br />
            <div id="agenda-text">
                <!-- <p style="font-family: 'Times New Roman'">
                    I.Разглеждане на инвентарни описи на учрежденски и лични фондове:
                </p> -->
                <span
                    style="font-family: 'Times New Roman'"
                    class="justify-conten-center"
                    v-for="item in model.standPointsData"
                    :key="item.id"
                >
                    <p style="font-family: 'Times New Roman'">
                        {{
                            `${item.index}. Ф. № ${item.fundNumber}, инв. оп. № ${item.inventoryNumber} ${item.fundTitle}`
                        }}
                    </p>
                    <p style="font-family: 'Times New Roman'">
                        {{ `Докладва:  ${item.displayName} ${item.jobTitle} ${item.department}` }}
                    </p>
                </span>
                <!-- <p style="font-family: 'Times New Roman'">{{ 'II. Разглеждане на докладни записки' }}</p> -->
                <p style="font-family: 'Times New Roman'">
                    {{
                        `Заседанието се ръководи от председателя на ${model.sessionTypeName} ${model.assignedToChairmanName}`
                    }}
                    <br />
                    <br />
                    <span
                        style="font-family: 'Times New Roman'"
                        v-for="item in model.standPointsDecision"
                        :key="item.id"
                    >
                        <p style="font-family: 'Times New Roman'">
                            {{ `${model.assignedToChairmanName}: ${item.index} точка от дневния ред е ${item.title}` }}
                        </p>
                        <p style="font-family: 'Times New Roman'">{{ `${item.reporterInfo}` }}</p>
                        <span class="justify-conten-center" v-for="s in model.standPointsData" :key="s.id">
                            <span class="justify-conten-center" v-for="i in s.reportStandpoint" :key="i.id">
                                <p style="font-family: 'Times New Roman'" v-if="i.index == item.index">
                                    {{ `${i.standPointTextCreatorDisplayName}: ${i.standpointText}` }}
                                </p>
                                <p v-if="i.index == item.index" style="font-family: 'Times New Roman'">
                                    {{ `${i.reportCreatorDisplayName}: ${i.commentText}` }} <br />
                                </p>
                            </span>
                        </span>
                        <p style="font-family: 'Times New Roman'">
                            <br />{{ `Решение на ${model.sessionTypeName} на ${model.archiveName}: ` }}
                            {{ `${item.decision}` }}
                        </p>
                        <p style="font-family: 'Times New Roman'">{{ `Срок за утвърждаване:  ${item.deadLine}` }}</p>
                    </span>
                </p>
            </div>
            <br />
            <div>
                <p style="font-family: 'Times New Roman'">
                    <b> {{ ` ${model.directorName} ` }}</b>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    <b> {{ `${model.assignedToSecretarName} ` }}</b
                    ><br />
                    .................................
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; ..............................<br />
                    <span style="font-family: 'Times New Roman'">{{ `(Директор на ${model.archiveName})` }}</span>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;
                    <span style="font-family: 'Times New Roman'">{{ `(Секретар)` }}</span>
                </p>
            </div>
        </div>
    </v-container>
</template>
<script lang="ts">
import { defineComponent, ref, onMounted, PropType } from 'vue';
import { SessionProtocolDataModel } from '@/models/sessionProtocolData';
import commissionSessionService from '@/services/commissionSession.service';
import { formatDate } from '@/helpers/format.helper';
import router from '@/router';
import { useI18n } from 'vue-i18n';
import { SessionProtocol } from '@/models/protocol';
import { returnWordFromHtml } from '@/helpers/word.helper';

export default defineComponent({
    name: 'PrintTranscript',
    props: {
        id: {
            type: Number,
            required: true,
        },
        items: {
            type: Array as PropType<number[]>,
            required: false,
        },
    },

    setup(props) {
        const { t } = useI18n();
        const model = ref<SessionProtocolDataModel>(new SessionProtocolDataModel());
        const getProtocolDataModel = ref<SessionProtocol>(new SessionProtocol());

        const getProtocolData = async () => {
            getProtocolDataModel.value.id = props.id;
            getProtocolDataModel.value.standPointIds = props.items;
            model.value = await commissionSessionService.getSessionProtocolData(getProtocolDataModel.value);
        };
        const goBack = () => {
            router.go(-1);
        };

        const printButton = () => {
            window.print();
        };
        const exportHTMLtoWord = () => {
            returnWordFromHtml(document.getElementById('myProtocol')?.innerHTML as string);
        };

        onMounted(async () => {
            await getProtocolData();
            console.log(props.items as number[]);
        });

        return {
            t,
            formatDate,
            printButton,
            exportHTMLtoWord,
            goBack,
            model,
        };
    },
});
</script>

<style lang="scss" scoped>
@use '@/assets/styles/common.scss' as *;
@import '@/assets/styles/protocol.scss';

// .v-btn {
//     @include button;
//     margin: 5px 50px;
// }

// .cancel {
//     @include button(var(--ISDA-main-color4), var(--ISDA-main-color1));
//     margin-top: 18px;
// }

.v-card-title {
    border-bottom: 1px solid var(--ISDA-main-color1) !important;
    box-shadow: rgb(173, 173, 173) 0px 0px 5px 0px !important;
}

#signatures-first {
    display: flex;
}

#president-div,
#secretary-div {
    display: flex;
    width: 8cm;
    flex-wrap: wrap;
}

#members-s-li {
    display: flex;
    width: 8cm;
    flex-wrap: wrap;
}

#members-s {
    display: flex;
    width: 18cm;
    flex-wrap: wrap;
}

.cursor {
    cursor: pointer;
}
.offset {
    margin-left: 89px;
}
</style>
