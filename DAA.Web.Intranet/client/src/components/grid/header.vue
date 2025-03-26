<template>
  <thead class="thead-light">
    <tr>
      <th v-if="rowNumbers"></th>
      <th
        class="text-left"
        v-for="(col, index) in cols"
        :key="index"
        :class="{ active: sortKey == col.prop, invisible: col.visible == false}"
      >
        <div class="d-flex justify-content-between">
          <a href="#!" @click="sortBy( col.sortKey, col.prop, col.type)" v-if="col.sortable">
            {{ typeof col.title == "function" ? col.title() : col.title }}
            <i class="fa fa-sort" v-if="sortKey !== col.prop"></i>
            <i
              class="fa fa-sort-up"
              v-if="sortKey == col.prop && sortDirection === 1"
            ></i>
            <i
              class="fa fa-sort-down"
              v-if="sortKey == col.prop && sortDirection === -1"
            ></i>
          </a>
          <span v-else>{{ col.title }}</span>
          <div class="float-right pointer" v-if="col.filterable">
            <grid-filter
              :col="col"
              @apply="applyFilter"
              @clear="clearFilter"
            ></grid-filter>
          </div>
        </div>
      </th>
    </tr>
  </thead>
</template>

<script>
import filters from "./models/filters";
import Filter from "./filter.vue";

export default {
  name: "GridHeader",
  components: {
    "grid-filter": Filter,
  },
  props: {
    cols: {
      type: Array,
      required: true,
    },
    sortKey: {
      type: String,
      required: false,
    },
    rowNumbers: {
      type: Boolean,
      required: false,
      default: false,
    },
  },
  data() {
    return {
      sortkey: "",
      sortDirection: null,
      sortkeyType: "",
    };
  },
  methods: {
    applyFilter(val) {
      this.$emit("apply-filter", val);
    },
    clearFilter(val) {
      this.$emit("clear-filter", val);
    },
    sortBy(key, val, type) {
      this.sortkey = key == undefined ? val : key;
      this.sortDirection = (this.sortDirection || 1) * -1;
      this.sortkeyType = type;
      this.$emit("sort", { key: this.sortkey, direction: this.sortDirection, type: this.sortkeyType });
    },
  },
  filters: {
    ...filters,
  },
};
</script>

<style scoped>
th a {
  color: inherit;
  text-decoration: none !important;
}

th.active a {
  color: var(--bs-primary); /* bootstrap theme link color */
}

th.invisible {
  display: none; 
}

a.active {
  color: var(--bs-primary); /* bootstrap theme link color */
}

.pointer {
  cursor: pointer;
}

.filter-icon {
  float: right;
}
</style>