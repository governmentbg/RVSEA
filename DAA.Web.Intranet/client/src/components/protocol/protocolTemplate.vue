<template>
    <div class="Invisible">
        <div style="margin: auto; max-width: 18.5cm" ref="myProtocol">
            <div>
                <b
                    ><p style="font-family: 'Times New Roman'">
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; Утвърждавам:
                        <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        {{ `ДИРЕКТОР на ${model.archiveName}` }}
                        <br />&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        {{ `${model.directorName}` }}<br />
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                        {{ `Дата: ${formatDate(model.currentDate)} г.` }}
                    </p>
                </b>
            </div>
            <br />
            <h4 style="text-align: center; font-family: 'Times New Roman'">П Р О Т О К О Л</h4>
            <h4 style="text-align: center; font-family: 'Times New Roman'">{{ `№: ${model.protocolNumber}` }}</h4>
            <br />
            <p style="line-height: 1.5; text-indent: 45px; text-align: justify; font-family: 'Times New Roman'">
                {{
                    ` Днес, ${formatDate(
                        model.currentDate
                    )} г., се проведе заседание на Експертно - проверочната комисия`
                }}
                {{ `(${model.sessionTypeName}) на дирекция „${model.archiveName}, назначена със Заповед` }}
                {{
                    ` №: ........ ${formatDate(model.currentDate)}г. на директора на ${model.archiveName}, в
        състав: `
                }}
            </p>
            <p style="margin-bottom: 0px; font-family: 'Times New Roman'">
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
            <p style="line-height: 1.5; text-indent: 45px; text-align: justify; font-family: 'Times New Roman'">
                <b>Заседанието има кворум и може да взема решения.За неговото протичане бе приет следният</b>
            </p>
            <h5 style="text-align: center; font-family: 'Times New Roman'">Д Н Е В Е Н Р Е Д:</h5>
            <!-- <p style="font-family: 'Times New Roman'">
                I.Разглеждане на инвентарни описи на учрежденски и лични фондове:
            </p> -->
            <span class="justify-conten-center" v-for="item in model.standPointsData" :key="item.id">
                <p style="font-family: 'Times New Roman'">
                    {{ `${item.index}. Ф.№${item.fundNumber}, инв. оп.№${item.inventoryNumber} ${item.fundTitle}` }}
                </p>
                <p style="font-family: 'Times New Roman'">
                    {{ `Докладва:  ${item.displayName} ${item.jobTitle} ${item.department}` }}
                </p>
            </span>
            <!-- <p>{{ 'II. Разглеждане на докладни записки' }}</p> -->
            <p style="font-family: 'Times New Roman'">
                <b>
                    {{
                        `Заседанието се ръководи от председателя на ${model.sessionTypeName} ${model.assignedToChairmanName}`
                    }}</b
                >
                <br />
                <span style="font-family: 'Times New Roman'">
                    <br />
                    <b> Разглеждане на материалите от дневния ред:</b></span
                >
                <span v-for="item in model.standPointsDecision" :key="item.id">
                    <p style="font-family: 'Times New Roman'">
                        <b> {{ `По точка ${item.index}:` }}</b
                        >{{ item.title }}
                    </p>
                    <p style="font-family: 'Times New Roman'">{{ `${item.reporterInfo}` }}</p>
                    <span class="justify-conten-center" v-for="s in model.standPointsData" :key="s.id">
                        <span class="justify-conten-center" v-for="i in s.reportStandpoint" :key="i.id">
                            <p v-if="i.index == item.index" style="font-family: 'Times New Roman'">
                                {{ `${i.standPointTextCreatorDisplayName}: ${i.standpointText}` }}
                            </p>
                            <p v-if="i.index == item.index" style="font-family: 'Times New Roman'">
                                {{ `${i.reportCreatorDisplayName}:  ${i.commentText}` }} <br />
                            </p>
                        </span>
                    </span>
                    <p style="font-family: 'Times New Roman'">
                        <b> {{ `Решение на ${model.sessionTypeName}:` }}</b> {{ item.decision }}
                    </p>
                    <p style="font-family: 'Times New Roman'">
                        <b> {{ `Срок за утвърждаване: ${item.deadLine}` }}</b>
                    </p>
                </span>
            </p>
            <div>
                <p style="font-family: 'Times New Roman'">
                    <b>ПРЕДСЕДАТЕЛ:..................</b>
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;

                    <b>СЕКРЕТАР:..................</b><br />
                    <br />
                    <!-- ..............................
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; &nbsp;&nbsp;
                    ..............................<br /> -->
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    {{ `( ${model.assignedToChairmanName})` }}
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                    {{ `( ${model.assignedToSecretarName})` }}
                </p>
            </div>
            <div>
                <b style="font-family: 'Times New Roman'">ЧЛЕНОВЕ:</b><br />
                <br />
                <p
                    style="width: 18cm; font-family: 'Times New Roman'"
                    v-for="(item, index) in model.members"
                    :key="index"
                >
                    <span v-if="index % 2 === 0" style="width: 18cm">
                        <span style="font-family: 'Times New Roman'" v-if="model.members.length > index + 1">
                            {{ `${index + 1}` }}.............................................
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            {{ `${index + 2}` }}.............................................
                            <br />
                        </span>
                        <span style="font-family: 'Times New Roman'" v-else>
                            {{ `${index + 1}` }}.............................................
                            <br />
                        </span>
                        <span v-if="model.members.length > index + 1" style="font-family: 'Times New Roman'">
                            &nbsp;&nbsp;({{ item }}) &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                            <span v-if="item.length <= 30">
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
                                &nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;</span
                            >
                            ({{ model.members[index + 1] }})</span
                        >
                        <span style="font-family: 'Times New Roman'" v-else> &nbsp;&nbsp;({{ item }}) </span>
                    </span>
                    <br />
                </p>
            </div>
        </div>
    </div>
</template>
<script lang="ts">
import { defineComponent, ref, inject, Ref, watch } from 'vue';
import { GenerateProtocolModel, SessionProtocolDataModel } from '@/models/sessionProtocolData';
import commissionSessionService from '@/services/commissionSession.service';
import { formatDate } from '@/helpers/format.helper';
import { Message } from '@/models/notification';
import { ResponseResult } from '@/models/responseResult';
import { IMessage } from '@/interfaces/notification';
import router from '@/router';
import { useI18n } from 'vue-i18n';
import { SessionProtocol } from '@/models/protocol';

export default defineComponent({
    name: 'ProtocolTemplate',

    props: {
        sessionId: {
            type: Number,
            required: true,
        },
        generate: {
            type: Boolean,
            default: false,
        },
    },

    setup(props) {
        const { t } = useI18n();
        const model = ref<SessionProtocolDataModel>(new SessionProtocolDataModel());
        const sendModel = ref<GenerateProtocolModel>(new GenerateProtocolModel());
        const message = inject('notificationMessage') as Ref<IMessage>;
        const createProtocol = ref(false);
        const myProtocol = ref();
        const getProtocolDataModel = ref<SessionProtocol>(new SessionProtocol());

        const getProtocolData = async () => {
            getProtocolDataModel.value.id = props.sessionId;
            model.value = await commissionSessionService.getSessionProtocolData(getProtocolDataModel.value);
        };

        const generateProtocol = async () => {
            await getProtocolData();

            try {
                sendModel.value.sessionId = props.sessionId;
                sendModel.value.protocolNumber = model.value.protocolNumber as number;
                sendModel.value.content = new XMLSerializer().serializeToString(myProtocol.value);

                await commissionSessionService.generateSessionProtocol(sendModel.value);
                createProtocol.value = false;
                router.go(0);
            } catch (error: unknown) {
                const errorResult = error as ResponseResult;
                message.value = new Message({
                    text: errorResult.showMessage ? errorResult.message : t('error.basic'),
                    display: true,
                });
            }
        };

        // onMounted(async () => {
        //     await getProtocolData();
        // });

        watch(
            () => createProtocol.value,
            (val) => {
                if (val === true) {
                    generateProtocol();
                }
            }
        );
        const checkLength = (val: string) => {
            if (val.length > 30) {
                return false;
            } else true;
        };
        return {
            t,
            checkLength,
            formatDate,
            createProtocol,
            model,
            myProtocol,
        };
    },
    watch: {
        generate: function (val) {
            this.createProtocol = val;
        },
        createProtocol: function (val) {
            this.$emit('update:generate', val);
        },
    },
});
</script>

<style lang="scss" scoped>
.Invisible {
    display: none;
}
.offset {
    margin-left: 89px;
}
</style>
