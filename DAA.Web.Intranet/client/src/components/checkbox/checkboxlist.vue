<template>
  <!-- <div v-if="showGroups"> 
        <ul class="list-group" v-for="group in useGroupBy(items, 'groupName')" :key="group">
            <ul class="list-group" v-for="group in groupBy(items, 'groupName')" :key="group">
            <h5>{{group[0].groupName}}</h5>
            <li :key="item.id"  v-for="item in group" class="list-group-item list-group-item-action">
                <div class="form-check" :class="{ 'form-switch': enableSwitches }">
                <input 
                    :id="name + '_' + item.id" 
                    :name="name + '_' + item.id" 
                    :key="item.id" 
                    :value="!textAsValue ? item.code : item.text" 
                    type="checkbox" 
                    :disabled="readonly"
                    v-model="selectedItems"
                    class="form-check-input" />
                {{ item.text }}
                <small v-if="item.description">{{ item.description }}</small>
                </div>
            </li>
        </ul>
    </div>
    <div v-else>
        <ul class="list-group">
            <li :key="item.id"  v-for="item in items" class="list-group-item list-group-item-action">
                <div class="form-check" :class="{ 'form-switch': enableSwitches }">
                <input 
                    :id="name + '_' + item.id" 
                    :name="name + '_' + item.id" 
                    :key="item.id" 
                    :value="!textAsValue ? item.code : item.text" 
                    type="checkbox" 
                    :disabled="readonly"
                    v-model="selectedItems"
                    class="form-check-input" />
                {{ item.text }}
                <small v-if="item.description">{{ item.description }}</small>
                </div>
            </li>
        </ul>
    </div> -->

  <v-list v-if="enableGroups" :density="density" :disabled="disabled" expand>
    <v-list-group v-for="group in listGroups" :key="group">
      <template v-slot:activator="{ props }">
        <v-list-item
          v-bind="props"
          :title="group[0].groupName"
          :value="group[0].groupName"
        >
        </v-list-item>
      </template>
      <template v-for="item in group" :key="item">
        <v-list-item :density="density" :value="item[valueProp]">
          <v-switch
            v-if="enableSwitches"
            v-model="selectedItems"
            :label="item[labelProp]"
            :value="item[valueProp]"
            :density="density"
            hide-details="auto"
          />
          <v-checkbox
            v-else
            v-model="selectedItems"
            :label="item[labelProp]"
            :value="item[valueProp]"
            :density="density"
            hide-details="auto"
          />
        </v-list-item>
      </template>
    </v-list-group>
  </v-list>
  <v-list v-else :density="density" expand>
    <v-list-item v-for="item in items" :key="item" :density="density">
      <v-switch
        v-if="enableSwitches"
        v-model="selectedItems"
        :label="item[labelProp]"
        :value="item[valueProp]"
        :density="density"
        hide-details="auto"
        :disabled="disabled"
        :readonly="readonly"
      />
      <v-checkbox
        v-else
        v-model="selectedItems"
        :label="item[labelProp]"
        :value="item[valueProp]"
        :density="density"
        hide-details="auto"
        :disabled="disabled"
        :readonly="readonly"
      />
    </v-list-item>
  </v-list>
</template>

<script lang="ts">
import { computed, defineComponent, PropType } from 'vue';
import { IDropdownOption } from '@/interfaces/dropdown';
import { groupBy } from '@/helpers/format.helper';

export default defineComponent({
  name: "CheckboxList",
  props: {
    density: {
      type: String,
      default: "compact",
    },
    required: {
      type: Boolean,
      required: false,
      default: false,
    },
    readonly: {
      type: Boolean,
      required: false,
      default: false,
    },
    disabled: {
      type: Boolean,
      required: false,
      default: false,
    },
    enableSwitches: {
      type: Boolean,
      required: false,
      default: false,
    },
    enableGroups: {
      type: Boolean,
      required: false,
      default: false,
    },
    items: {
      type: Array as PropType<IDropdownOption[]>,
      required: true,
    },
    valueProp: {
      type: String,
      default: "id",
    },
    labelProp: {
      type: String,
      default: "label",
    },
    modelValue: {
      type: Array as PropType<IDropdownOption[]>,
      default: () => {
        return [];
      },
    },
  },
  setup(props, context) {
    const listGroups = computed(() => groupBy(props.items, "groupName"));

    const selectedItems = computed({
      get: () => props.modelValue,
      set: (value) => context.emit("update:modelValue", value),
    });

    return {
      selectedItems,
      listGroups,
    };
  },
});
</script>
