<template>
  <span>
    <textarea
      id="issue_template_json_setting_field"
      :value="value"
      @input="$emit('input', $event.target.value)"
      rows=6
      :placeholder="placeholder"
      v-if="format == 'text'">
    </textarea>
    <input
      id="issue_template_json_setting_field"
      type="text"
      :placeholder="placeholder"
      :value="value"
      @input="$emit('input', $event.target.value)"
      v-if="format == 'string'" />
    <input
      id="issue_template_json_setting_field"
      type="number"
      :placeholder="placeholder"
      :max="max"
      :min="min"
      :value="value"
      @input="$emit('input', $event.target.value)"
      v-if="format == 'int'" />
    <input
      id="issue_template_json_setting_field"
      type="date"
      :value="value"
      @input="$emit('input', $event.target.value)"
      v-if="format == 'date'" />
    <select
      :value="value"
      @change="$emit('input', $event.target.value)"
      v-if="format == 'ratio'">
      <option />
      <option :key="ratio" v-for="ratio in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]">
        {{ ratio }} %
      </option>
    </select>
    <select
      id="value_selector"
      :multiple="multiple"
      @change="handleChangeSelect"
      v-if="['list', 'bool'].includes(format)">
      <option :disabled="multiple" />
      <option :selected="value?.includes?.(val)" :key="val" v-for="val in options">{{ val }}</option>
    </select>
  </span>
</template>

<script>
export default {
  name: 'FieldValue',
  props: {
    placeholder: String,
    value: [String, Number, Array],
    format: String,
    min: Number,
    max: Number,
    multiple: Boolean,
    options: {
      type: Array,
      default() {
        return [];
      }
    }
  },
  methods: {
    handleChangeSelect(event) {
      const selected = [...event.target.options].filter((opt) => opt.selected);
      const values = selected.map((opt) => opt.value);
      this.$emit('input', values);
    },
  },
};
</script>
