<template>
  <div>
    <p>
      <label><%= l(:label_select_field, default: "Select a field") %></label>
      <select id="field_selector" v-model="newItemTitle">
        <option :key="key" :value="key" v-for="(value, key) in customFields">
        {{ value.name }}
        </option>
      </select>
      <a class="icon icon-help template-help"
         title="<%= l(:help_for_this_field) %>"
         data-tooltip-area="builtin_fields_help_area"
         data-tooltip-content="builtin_fields_help_content">
        <%= l(:help_for_this_field) %>
        <span class="tooltip-area" id="builtin_fields_help_area"></span>
      </a>
    </p>
    <p>
      <label for="value_selector">
        <%= l(:field_value) %>
      </label>
      <field-value
        placeholder="<%= l(:enter_value, default: 'Please enter a value') %>"
        :max="currentField?.max_length"
        :min="currentField?.min_length"
        :multiple="currentField?.multiple"
        :options="currentField?.possible_values || []"
        :format="fieldFormat"
        v-model="newItemValue"
      />
      <span style="margin-left: 4px;" class="icon icon-add" v-on:click="addField(newItemTitle, newItemValue)">
        <%= l(:button_add) %>
      </span>
    </p>
    <div id="field_information" class="wiki" v-if="newItemTitle != ''">
      <b><%= l(:label_field_information, default: "Field information") %></b>
      <pre>{{ currentField }}</pre>
    </div>
    <div id="fields_setting_display_area">
      <ul class="json-list" v-if="items.length > 0">
        <li :key="item.title" v-for="item in items">
          <span v-if="customFields[item.title]">
            <b>{{ customFields[item.title].name }}</b>: {{ item.value }} / {{ item.title }}
          </span>
          <span v-if="!customFields[item.title]">
            <i class="issue_template help_content">
              <%= l(:unavailable_fields_for_this_tracker, default: "Unavailable field for this tarcker") %>
              : {{ item.value }} / {{ item.title }}
            </i>
          </span>
          <i class="icon icon-del" v-on:click="deleteField(item)"></i>
        </li>
      </ul>
      <pre id="builtin_fields_data_via_vue" style="display: none;">{{ items }}</pre>
      <span class="icon icon-reload" id="reset-json" v-on:click="loadField()">
        <%= l(:button_reset) %>
      </span>
      <span class="icon icon-checked" id="paste-json">
        <%= l(:button_apply) %>
      </span>
    </div>
    <!-- buildin field Generator -->
    <p style="opacity: 0.6;">
      <%= f.text_area :builtin_fields,
                      required: false,
                      cols: 60,
                      rows: 4,
                      label: l(:label_builtin_fields_json, default: "JSON for fields")
      %>
    </p>
    <div id="builtin_fields_help_content" class="wiki" style="display: none;">
      <%= l(:label_builtin_fields_help_message, default: "Enter builtin filds or custom fields default values with JSON format. ") %>
    </div>
  </div>
</template>

<script>
import FieldValue from './FieldValue.vue';

const AVAILABLE_FORMATS = [
  'int',
  'data',
  'ratio',
  'list',
  'bool',
  'string',
  'text',
];

export default {
  // eslint-disable-next-line vue/no-shared-component-data, vue/no-deprecated-data-object-declaration
  props: {
    templateId: String,
    projectId: String,
    trackerPulldownId: String,
    base_builtin_fields: {
      type: Object,
      default() {
        return {};
      },
    },
    relativeUrlRoot: String,
  },
  components: { FieldValue },
  data() {
    return {
      items: [],
      customFields: {},
      newItemTitle: '',
      newItemValue: '',
      api_builtin_fields: {},
      api_custom_fields: {},
      customFieldUrl: ''
    };
  },
  methods: {
    addField: function (newFieldName, newFieldValue) {
      if (newFieldName === '' || newFieldValue === '') {
        return
      }
      this.items.push({
        title: newFieldName,
        value: newFieldValue
      })
      this.newFieldName = ''
      this.newFieldValue = ''
    },
    deleteField: function (target) {
      this.items = this.items.filter(function (item) {
        return item !== target
      })
    },
    loadField: function () {
      this.api_builtin_fields = this.base_builtin_fields;
      // this.api_custom_fields = this.base_custom_fields;
      this.items = [];
      if (this.api_builtin_fields) {
        for (const [key, value] of Object.entries(this.api_builtin_fields)) {
          this.items.push({
            title: key,
            value: value
          });
        }
      }
      // { "issue_priority_id":"Priority", "issue_start_date":"Start date" }
      // if (this.api_custom_fields) {
      //   for (const [key, value] of Object.entries(this.api_custom_fields)) {
      //     this.customFields[key] = value
      //   }
      // }
    },
  },
  mounted: async function () {
    const trackerPulldown = document.getElementById(this.trackerPulldownId);
    if (trackerPulldown?.value) {
      this.$el.style.display = 'block';
      this.customFields = await this.getCustomFields(trackerPulldown?.value);
      trackerPulldown.addEventListener('change', async (event) => {
        if (event.target.value === '') {
          this.$el.style.display = 'none';
        } else {
          this.$el.style.display = 'block';
          this.customFields = await this.getCustomFields(event.target.value);
        }
      });
    } else {
      this.$el.style.display = 'none';
    }
    this.loadField();
  },
  computed: {
    currentField: function () {
      const fields = this.customFields;
      const title = this.newItemTitle;
      return fields[title];
    },
    fieldFormat: function () {
      const fields = this.customFields;
      const title = this.newItemTitle;
      const format = fields[title]?.field_format;
      if (AVAILABLE_FORMATS.includes(format)) {
        return format;
      }
      return 'text';
    },
  },
  watch: {
    newItemTitle: function (val) {
      if (typeof this.relativeUrlRoot === 'undefined') {
        this.customFieldUrl = ''
        return
      }

      let field = this.customFields[val]
      if (field == null || field.type != 'IssueCustomField') {
        this.customFieldUrl = ''
        return
      }
      this.customFieldUrl = this.relativeUrlRoot + '/custom_fields/' + field.id + '/edit'
    }
  }
}
</script>
