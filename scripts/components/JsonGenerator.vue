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
      <textarea
        id="issue_template_json_setting_field"
        placeholder="<%= l(:enter_value, default: 'Please enter a value') %>"
        rows=6
        v-model="newItemValue"
        v-if="fieldFormat() == 'text'">
      </textarea>
      <input
        id="issue_template_json_setting_field"
        type="text"
        placeholder="<%= l(:enter_value, default: 'Please enter a value') %>"
        v-model="newItemValue"
        v-if="fieldFormat() == 'string'">
      <input
        id="issue_template_json_setting_field"
        type="number"
        placeholder="<%= l(:enter_value, default: 'Please enter a value') %>"
        :max="customFields[newItemTitle].max_length"
        :min="customFields[newItemTitle].min_length"
        v-model="newItemValue"
        v-if="fieldFormat() == 'int'">
      <input
        type="date"
        id="issue_template_json_setting_field"
        v-model="newItemValue"
        v-if="fieldFormat() == 'date'">
      <select v-model="newItemValue" v-if="fieldFormat() == 'ratio'">
        <option v-for="ratio in [10, 20, 30, 40, 50, 60, 70, 80, 90, 100]">{{ ratio }} %</option>
      </select>
      <select
        id="value_selector"
        :multiple="customFields[newItemTitle].multiple == true"
        v-model="newItemValue"
        v-if="fieldFormat() == 'list' || fieldFormat() == 'bool'">
        <option v-for="value in possibleValues()">{{ value }}</option>
      </select>
      <span style="margin-left: 4px;" class="icon icon-add" v-on:click="addField(newItemTitle, newItemValue)">
        <%= l(:button_add) %>
      </span>
    </p>
    <div id="field_information" class="wiki" v-if="newItemTitle != ''">
      <b><%= l(:label_field_information, default: "Field information") %></b>
      <pre>{{ customFields[newItemTitle] }}</pre>
    </div>
    <div id="fields_setting_display_area">
      <ul class="json-list" v-if="items.length > 0">
        <li v-for="item in items">
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
export default {
  // eslint-disable-next-line vue/no-shared-component-data, vue/no-deprecated-data-object-declaration
  props: {
    baseUrl: String,
    templateId: String,
    projectId: String,
    trackerPulldownId: String,
    base_builtin_fields: {
      type: Object,
      default() {
        return {};
      },
    },
    base_custom_fields: {
      type: Object,
      default() {
        return {};
      },
    },
    relativeUrlRoot: String,
  },
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
      this.api_custom_fields = this.base_custom_fields;
      this.items = []
      if (this.api_builtin_fields) {
        for (const [key, value] of Object.entries(this.api_builtin_fields)) {
          this.items.push({
            title: key,
            value: value
          })
        }
      }
      // { "issue_priority_id":"Priority", "issue_start_date":"Start date" }
      if (this.api_custom_fields) {
        for (const [key, value] of Object.entries(this.api_custom_fields)) {

          this.customFields[key] = value
        }
      }
    },
    updateSelectableField: function () {
      let tmpFields = {}
      if (this.api_custom_fields) {
        for (const [key, value] of Object.entries(this.api_custom_fields)) {
          tmpFields[key] = value
        }
      }
      this.customFields = tmpFields
    },
    fieldFormat: function () {
      const fields = this.customFields
      const title = this.newItemTitle
      if (fields[title] && fields[title].field_format) {
        const format = fields[title].field_format
        if (format === 'int' || format === 'date' || format === 'ratio' ||
          format === 'list' || format === 'bool' || format === 'string') {
          return fields[title].field_format
        }
      }
      return 'text'
    },
    possibleValues: function () {
      const fields = this.customFields
      const title = this.newItemTitle
      return fields[title].possible_values
    }
  },
  mounted: function () {
    const trackerPulldown = document.getElementById(this.trackerPulldownId)
    if (trackerPulldown) {
      if (trackerPulldown.value === '') {
        this.$el.style.display = 'none'
      }
      trackerPulldown.addEventListener('change', event => {
        if (event.target.value === '') {
          this.$el.style.display = 'none'
          return
        }
        this.$el.style.display = 'block'
        const trackerId = event.target.value
        let url = this.baseUrl + '?tracker_id=' + trackerId + '&template_id=' + this.templateId
        if (typeof this.projectId !== 'undefined') {
          url += '&project_id=' + this.projectId
        }
        window.fetch(url)
          .then((response) => {
            return response.text()
          })
          .then((data) => {
            let obj = JSON.parse(data)
            this.api_custom_fields = obj.custom_fields
            this.updateSelectableField()
          })
      })
    }
    this.loadField()
  },
  computed: {
    // not yet
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
