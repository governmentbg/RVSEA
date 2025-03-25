<template>
    <table>
        <tr class="tr4">
            <td class="alignCenter" :style="styleBorder" colspan="2">
                <div class="positionLeft d">
                    <div class="value">{{ getCountry(data.country) }}</div>
                    <div class="label">{{ t("filmCards.printedCard.country") }}</div>
                </div>
                <div class="positionRight d">
                    <div class="value">{{ data.city }}</div>
                    <div class="label">{{ t("filmCards.printedCard.city") }}</div>   
                </div>
            </td>
            <td class="tdCol2" :style="styleBorder" rowspan="2">
                <div class="value">{{ data.archive }}</div>
                <div class="label">{{ t("filmCards.printedCard.archiveCopies") }}</div>
            </td>
        </tr>
        <tr class="tr1">
            <td :style="styleBorder" colspan="2">
                <div class="value valueMoz1">{{ data.archiveOriginals }}</div>
                <div class="label">{{ t("filmCards.printedCard.archiveOriginals") }}</div>
            </td>
        </tr>
        <tr class="tr2">
            <td :style="styleBorder" colspan="2">
                <div class="value valueMoz2">{{ data.documentsCipher }}</div>
                <div class="label">{{ t("filmCards.printedCard.documentsCipher") }}</div>
            </td>
            <td class="alignCenter" :style="styleBorder">
                <div class="value valueMoz3">
                    <div>{{ copiesCipher1 }}</div>
                    <div>{{ copiesCipher2 }}</div>
                </div>
                <div class="label">{{ t("filmCards.printedCard.copiesCipher") }}</div>
            </td>
        </tr>
        <tr class="tr3">
            <td :style="styleBorder" rowspan="2" colspan="2">
                <div class="value valueMoz4">{{ data.title }}</div>
                <div class="label">{{ t("filmCards.printedCard.archiveEntitytitle") }}</div>
            </td>
            <td class="tdCol2 td1" :style="styleBorder">
                <div class="value value2 valueMoz5">{{ copyType }}</div>
                <div class="label">{{ t("filmCards.printedCard.copyType") }}</div>
            </td>
        </tr>
        <tr class="tr4 alignCenter">
            <td class="td1" :style="styleBorder">
                <div class="value valueMoz5">{{ data.documentsFormat }}</div>
                <div class="label">{{ t("filmCards.printedCard.format") }}</div>
            </td>
        </tr>
        <tr class="tr4 alignCenter">
            <td :style="styleBorder" colspan="2">
                <div class="value">{{ endDates }}</div>
                <div class="label">{{ t("filmCards.printedCard.endDates") }}</div>
            </td>
            <td :style="styleBorder">
                <div class="value">{{ acceptedOn }}</div>
                <div class="label">{{ t("filmCards.printedCard.acceptedOn") }}</div>
            </td>
        </tr>
        <tr class="tr4">
            <td class="alignCenter" :style="styleBorder">
                <div class="value">{{ data.documentsLanguage?.join(", ") }}</div>
                <div class="label">{{ t("filmCards.printedCard.documentsLanguage") }}</div>
                </td>
            <td class="alignCenter" :style="styleBorder">
                <div class="value">{{ data.filmingExtent }}</div>
                <div class="label">{{ t("filmCards.printedCard.filmingExtent") }}</div>
            </td>
            <td class="tdCol2" :style="styleBorder" rowspan="2">
                <div class="value value3 valueMoz6">{{ data.copyVolume }}</div>
                <div class="label">{{ t("filmCards.printedCard.copyVolume") }}</div>
            </td>
        </tr>
        <tr class="tr4 alignCenter">
            <td :style="styleBorder" colspan="2">
                <div class="value">{{ data.source }}</div>
                <div class="label">{{ t("filmCards.printedCard.nameOfPersonFoundDocuments") }}</div>
            </td>
        </tr>
        <tr class="tr4" :style="styleBorder">
            <td colspan="3">
                <div class="value">{{ notes }}</div>
                <div class="label">{{ t("filmCards.printedCard.note") }}</div>
            </td>
        </tr>
    </table>
    <!-- добавям го за да се получи място между таблиците при печатане; с падинг например не става -->
    <div>&nbsp;</div>
    <table class="t2">
        <tr class="tr4" :style="styleBorder">
            <td class="label alignCenter td2" :style="styleBorder">
                {{ t("filmCards.printedCard.documentsCharacteristics") }}
            </td>
        </tr>
        <tr>
            <td class="verticalAlignTop" :style="styleBorder">
                {{ data.documentsCharacteristics }}
            </td>
        </tr>
        <tr class="paddingBottom1 tr4" :style="styleBorder">   
            <td>
                <div>
                    {{ `${t("filmCards.printedCard.date")} ${createdOn}` }}
                </div>
                <div>
                    {{ `${t("filmCards.printedCard.createdBy")} ${data.createdByDisplayName ? data.createdByDisplayName : ''}` }}
                </div>
            </td>
        </tr>
    </table>    
</template>
<script lang="ts">
import { defineComponent, inject, ref, Ref, computed } from "vue";
import { useI18n } from "vue-i18n";
import filmCardService from "@/services/filmCard.service";
import { Message } from "@/models/notification";
import { IMessage } from "@/interfaces/notification";
import { PrintedFilmCard } from "@/models/film";
import { formatPartiteDate, trimText, formatDate } from '@/helpers/format.helper';
import { CopyType } from '@/enums/films';

export default defineComponent({
    name: "PrintFilmCard",
    props: {
        cardId: {
            type: String,
            required: true,
        },
  },
  setup(props) {
    const { t } = useI18n();
    const message = inject("notificationMessage") as Ref<IMessage>; 

    const data = ref<PrintedFilmCard>(new PrintedFilmCard()); 
    const styleBorder = ("border:1px solid black"); 
    
    const getCountryCodeMainPart = (countryCode: string | null) => {
        if (!countryCode) {
            return "";
        }
        const delimeterIndex = countryCode.indexOf(" -");
        if (delimeterIndex < 0) {
            return countryCode;
        }

        return countryCode.substring(0, delimeterIndex)
    }
    const getCountry = (countryWithCode: string | null) => {
        if (!countryWithCode) {
            return "";
        }
        const delimeterIndex = Math.max(countryWithCode.lastIndexOf(" - "), countryWithCode.lastIndexOf(" – "));
        if (delimeterIndex < 0) {
            return countryWithCode;
        }

        return countryWithCode.substring(delimeterIndex + 3, countryWithCode.length)
    }
    const copiesCipher1 = computed(() => `${t("filmCards.printedCard.kmf")} ${getCountryCodeMainPart(data.value.countryCode)}`); 
    const copiesCipher2 = computed(() => `${t("filmCards.printedCard.inventoryNumber")} ${(data.value?.number ? data.value?.number : "")}`); 
    const endDates = computed(() => {
        const startDate = formatPartiteDate(data.value.startDateYear, data.value.startDateMonth, data.value.startDateDay);
        const endDate = formatPartiteDate(data.value.endDateYear, data.value.endDateMonth, data.value.endDateDay);
        let endDates = "";
        if (startDate || endDate) {
            endDates = `${startDate} - ${endDate}`;
        }

        return endDates;
    });
    const acceptedOn = computed(() =>     
        formatPartiteDate(data.value.acceptedOnYear, data.value.acceptedOnMonth, data.value.acceptedOnDay));
    const documentsCipher = computed(() => trimText(data.value.documentsCipher, 250));
    const notes = computed(() => trimText(data.value.notes, 80));
    const createdOn = computed(() => data.value.createdOn ? formatDate(data.value.createdOn.toString()) : '');
    const copyType = computed(() => {
        let result = "";
        switch(data.value.copyType) {
            case CopyType.photo: result = t("filmCards.printedCard.copyTypePhoto"); 
                break; 
            case CopyType.digital: result = t("filmCards.printedCard.copyTypeDigital"); 
                break; 
            case CopyType.film: result = t("filmCards.printedCard.copyTypeFilm"); 
                break; 
            case CopyType.microfilmNegative: result = t("filmCards.printedCard.copyTypeMicrofilmNegative"); 
                break; 
            case CopyType.microfilmPositive: result = t("filmCards.printedCard.copyTypeMicrofilmPositive"); 
                break; 
        }

        return result;
    });

    const getData = async () => { 
      try {
        data.value = await filmCardService.displayPrintedFilmCard(props.cardId);
      } catch (error: unknown) {
        message.value = new Message({
          text: t("filmCards.printedCard.error"),
          display: true,
        });
      }
    }

    getData();

    return {
      t,
      data,
      copiesCipher1,
      copiesCipher2,
      endDates,
      acceptedOn,
      copyType,
      styleBorder,
      documentsCipher,
      notes,
      createdOn,
      getCountry,
    };
  },
});
</script>

<style lang="scss" scoped>
    .tdCol2 {
        width: 60mm;
        text-align: center;
    }

    .value {
        font-size: 4mm;
        min-height: 4mm;
    }

    .positionLeft {
        width: 50%;
        float: left;
    }

    .positionRight {
        width: 50%;
        float: right;
    }

    tr > td > .value {
        top: 4mm;
        position: relative;
        height: 100%;
    }

    .tr4 > td > .d {
        top: 0mm;
        position: relative;
        height: 100%;
    }

    tr > .tdCol2 > .value {
        top: 8mm;
        position: relative;
        height: 100%;
    }

    tr > .tdCol2 > .value3 {
        top: 12mm;
        position: relative;
        height: 100%;
    }

    .tr3 > td > .value2 {
        top: 3mm;
        position: relative;
        height: 100%;
    }

    .label {
        font-size: 3mm;
        font-weight: bold;
    }

    .tr1 {
        height: 16mm;
    }

    .tr2 {
        height: 25mm;
    }

    .tr4 {
        height: calc((108mm - 56mm)/5);
    }

    td {
        vertical-align: bottom;
        padding: 0.5mm;
        line-height: 4mm;
    }

    .td1 {
        height: calc(25mm/2);
    }

    .td2 {
        vertical-align: middle;
    }

    table {
        width: 200mm;
        height: 108mm;
        margin-bottom: 10mm;
    }

    .t2 {
        width: 200mm;
        height: 90mm;
    }

    .alignCenter {
        text-align: center;
    }

    .alignLeft {
        text-align: left;
    }

    .paddingBottom1 {
        padding-bottom: 10mm;
    }

    .verticalAlignTop {
        vertical-align: top;
    }

    /** Mozilla Firefox */
    @-moz-document url-prefix() {
        tr > .tdCol2 > .value {
            top: -13mm;
        }

        tr > td > .value {
            top: -1mm;
        }

        .valueMoz1 {
            top: -6mm!important;
        }

        .valueMoz2 {
            top: -15mm!important;
        }

        .valueMoz3 {
            top: -12mm!important;
        }

        .valueMoz4 {
            top: -23mm!important;
        }

        .valueMoz5 {
            top: 0mm!important;
        }

        .valueMoz6 {
            top: -6mm!important;
        }

        table {
            margin: 5mm;
        }
    }
</style>
