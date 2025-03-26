<template>
  <div>
    <a v-if="href" 
      :href="href" 
      :class="cssClass" 
      :target="target" 
    >{{ 
      linkTitle 
    }}</a>
    <router-link 
      v-if="to"
      :to="to" 
      :class="cssClass" 
      :target="target"
    >{{
      linkTitle
    }}</router-link>
    <div>
          <span :class="descriptionCssClass">{{ description }}</span>
    </div>
  </div>
</template>
<script lang="ts">
import { computed, defineComponent, PropType } from "vue";
import { RouteLocationRaw, useRouter } from "vue-router";

export default defineComponent({
  name: "Hyperlink",
  props: {
    to: {
      type: [Object, String] as PropType<RouteLocationRaw>,
    },
    href: {
      type: String,
    },
    title: {
      type: String,
    },
    description: {
      type: String,
    },
    target: {
      type: String,
      default: "_self",
    },
    cssClass: {
      type: String,
      default: "link-primary",
    },
    descriptionCssClass: {
      type: String,
      default: "text-body-2",
    },
  },
  setup(props) {
    const router = useRouter();
    const linkTitle = computed(
      () => props.title ?? (props.to ? router.resolve(props.to).fullPath : (props.href ?? ''))
    );   
    return {
      linkTitle,
    };
  },
});
</script>
