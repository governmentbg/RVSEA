<template>
  <v-snackbar
    :color="type"
    :timeout="timeout"
    multi-line
    app
    v-model="visible"
    location="top"
  >
    {{ text }}

    <template v-slot:actions>
      <v-btn 
        color="white"  
        variant="text" 
        @click="hide"
      >
        {{ t('common.close') }}
      </v-btn>
    </template>
  </v-snackbar>
</template>
<script lang="ts">
  import { useI18n } from 'vue-i18n';
  import { IMessage } from "@/interfaces/notification";
  import { computed, defineComponent, PropType, ref, watch } from "vue";

  export default defineComponent({
    name: "NotificationMessage",
    props: {
      options: {
        type: Object as PropType<IMessage>,
      },
      // title: {
      //     type: String,
      // },
      // text: {
      //     type: String,
      // },
      // type: {
      //     type: String,
      //     validator: (value: string) => {
      //         return [
      //             'info',
      //             'error',
      //             'success',
      //             'warning',
      //             ].includes(value)
      //     },
      //     default : 'error'
      // },
      // timeout: {
      //     type: Number,
      //     default: -1,
      // },
    },
    setup(props) {
      const { t } = useI18n();

      const visible = ref(props.options?.display ?? false);

      const text = computed(() => props.options?.text ?? "");
      const type = computed(() => props.options?.type ?? "error");
      const timeout = computed(() => props.options?.timeout ?? -1);

      const hide = () => {
        visible.value = false;
      };

      watch(
        () => props.options,
        (val) => {
          console.log(val);
          visible.value = val?.display ?? false;
        }
      );

      return {
        t,
        visible,
        text,
        type,
        timeout,
        hide,
      };
    },
  });
</script>
