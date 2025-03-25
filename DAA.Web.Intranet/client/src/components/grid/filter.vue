<template>
  <Popper trigger="click" placement="bottom" ref="pop">
    <button
      class="btn btn-link popper-btn"
      type="button"
      v-bind:class="{ 'not-applied': !isApplied }"
    >
      <i class="fa fa-filter"></i>
    </button>
    <template #content>
      <form @submit="applyFilter">
        <div class="mb-3">
          <label v-if="col.type!='boolean'">{{$t('grid.filter.operator')}}</label>
          <select
            class="form-control"
            v-model="operator"
            v-if="col.type == 'number' || col.type == 'int' || col.type == 'date'"
            required
          >
            <option value="==">{{$t('grid.filter.equals')}}</option>
            <option value=">">{{$t('grid.filter.greatThan')}}</option>
            <option value="<">{{$t('grid.filter.lessThan')}}</option>
          </select>
          <select
            class="form-control"
            v-model="operator"
            v-if="col.type == 'text' || col.type == 'string' || col.type == 'html'"
            required
          >
            <option value="==">{{$t('grid.filter.equals')}}</option>
            <option value="~">{{$t('grid.filter.contains')}}</option>
            <option value="/">{{$t('grid.filter.startsWith')}}</option>
          </select>
        </div>
        <div class="mb-3">
          <label>{{$t('grid.filter.value')}}</label>
          <input
            type="text"
            class="form-control"
            v-model="value"
            v-if="col.type == 'text' || col.type == 'string' || col.type == 'html'"
            required
          />
          <input
            type="number"
            class="form-control"
            v-model="value"
            v-if="col.type == 'number' || col.type == 'int'"
            required
          />
          <input
            type="date"
            class="form-control"
            v-model="value"
            v-if="col.type == 'date'"
            required
          />
          <input
            type="text"
            class="form-control"
            v-model="value"
            v-if="col.type == 'boolean'"
            required
          />
        </div>
        <div class="text-center">
          <button class="btn btn-primary btn-sm me-1" type="submit">{{$t('grid.filter.apply')}}</button>
          <button
            class="btn btn-secondary btn-sm ms-1"
            type="button"
            @click="clearFilter"
            v-if="isApplied"
          >
            {{$t('grid.filter.clear')}}
          </button>
        </div>
      </form>
    </template>
  </Popper>
</template>

<script>
import Popper from "vue3-popper";

export default {
  components: {
    Popper,
  },
  props: {
    col: { type: Object, required: true },
  },
  setup() {
    return {};
  },
  data() {
    return {
      isApplied: false,
      operator: "",
      value: "",
      type: ""
    };
  },
  methods: {
    applyFilter(e) {
      e.preventDefault();
      this.isApplied = true;
      if (this.col.type == "boolean") {
        this.operator = "==";
      }
      this.$emit("apply", {
        operator: this.operator,
        value: this.value,
        col: this.col,
        type: this.col.type
      });

      this.$refs.pop.close();
    },
    clearFilter() {
      this.isApplied = false;
      this.value = null;
      this.operator = null;
      this.$emit("clear", this.col);
      this.$refs.pop.close();
    },
  },
};
</script>
<style scoped>
.popper-btn {
  padding: 0;
}

.not-applied {
  color: grey;
}
</style>
