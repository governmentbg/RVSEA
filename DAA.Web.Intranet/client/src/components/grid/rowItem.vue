<template>
    <div v-if="col.type === 'vue'">
      <component
        :is="col.template(row.items).template"
        :templateArgs="col.template(row.items).templateArgs"
      >
      </component>
    </div>
    <div v-else class="value-wrapper" @click="onClick">
      <span v-if="col.type === 'date'">{{ formatDate(row.items[col.prop]) }}</span>
      <div
        class="html-output"
        v-else-if="col.type === 'html'"
        v-html="renderValue(row.items[col.prop])"
      ></div>

      <span v-else>{{ renderValue(row.items[col.prop]) }}</span>
    </div>
</template>

<script >
import customFilters from "./models/filters";
export default {
  name: "RowItem",
  props: {
    col: { type: Object, required: true },
    row: { type: Object, required: true }
  },
  filters: {
    ...customFilters,
  },
  methods: {
    formatDate(item) {
      if (this.col.renderFunction) {
        return this.col.renderFunction(item);
      } else {
        return new Date(item).toLocaleString();
      }
    },
    renderValue(item) {
      if (this.col.renderFunction) {
        return this.col.renderFunction(item);
      } else {
        return item;
      }
    },
    onClick() {
      this.$emit("click", { column: this.col.prop, rowItems: this.row.items } );
    },
  },
};
</script>

<style lang="scss" scoped>
.value-wrapper {
  //max-height: 100px;
  overflow: visible;
}
</style>