<template>
  <div id="fields_setting_display_area">
    <ul class="json-list" v-if="items.length > 0">
      <li :key="`${item.title}-${item.value}`" v-for="item in items">
        <span v-if="item.field">
          <b>{{ item.field.name }}</b>: {{ item.value }} / {{ item.title }}
        </span>
        <span v-if="!item.field">
          <i class="issue_template help_content">
            {{ l('unavailable_fields_for_this_tracker') }}
            : {{ item.value }} / {{ item.title }}
          </i>
        </span>
        <i class="icon icon-del" v-on:click="$emit('delete', item)"></i>
      </li>
    </ul>
  </div>
</template>

<script>
export default {
  name: 'DisplayArea',
  props: {
    items: {
      type: Array,
      default() {
        return [];
      },
    },
  },
};
</script>
