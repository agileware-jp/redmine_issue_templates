<template>
  <div id="json_generator">
    <p>
      <label>{{ l('label_select_field') }}</label>
      <select id="field_selector" v-model="model.title">
        <option value=""></option>
        <option :key="key" :value="key" v-for="(value, key) in customFields">
        {{ value.name }}
        </option>
      </select>
      <a class="icon icon-help template-help"
         :title="l('help_for_this_field')"
         data-tooltip-area="builtin_fields_help_area"
         data-tooltip-content="builtin_fields_help_content">
        {{ l('help_for_this_field') }}
        <span class="tooltip-area" id="builtin_fields_help_area"></span>
      </a>
    </p>
    <p>
      <label for="value_selector">
        {{ l('field_value') }}
      </label>
      <field-value
        :placeholder="l('enter_value')"
        :max="currentField?.max_length"
        :min="currentField?.min_length"
        :multiple="currentField?.multiple"
        :options="currentField?.possible_values || []"
        :format="fieldFormat"
        v-model="model.value"
      />
      <span style="margin-left: 4px;" class="icon icon-add" v-on:click="addField">

        {{ l('button_add') }}
      </span>
    </p>
    <div id="field_information" class="wiki" v-if="model.title != ''">
      <b>{{ l('label_field_information') }}</b>
      <pre>{{ currentField }}</pre>
    </div>
    <display-area :items="items" v-on:delete="deleteField" />
    <p>
      <span class="icon icon-reload" id="reset-json" v-on:click="loadField">
        {{ l('button_reset') }}
      </span>
      <span class="icon icon-checked" v-on:click="applyJson">
        {{ l('button_apply') }}
      </span>
    </p>
    <!-- buildin field Generator -->
    <p style="opacity: 0.6;">
      <label :for="`${templateType}_builtin_fields`">
        {{ l('label_builtin_fields_json') }}
      </label>
      <textarea
        :id="`${templateType}_builtin_fields`"
        :name="`${templateType}[builtin_fields]`"
        cols="60"
        rows="4"
        :value="json">
      </textarea>
    </p>
  </div>
</template>

<script>
import DisplayArea from './DisplayArea.vue';
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
    builtinFields: {
      type: Object,
      default() {
        return {};
      },
    },
    templateType: String,
    trackerPulldownId: String,
  },
  components: { DisplayArea, FieldValue },
  data() {
    return {
      json: '',
      items: [],
      customFields: {},
      model: {
        title: '',
        value: '',
      },
    };
  },
  methods: {
    addField: function () {
      if (this.model.title === '' || this.model.value === '') {
        return;
      }
      this.items.push({
        title: this.model.title,
        value: this.model.value,
        field: this.customFields[this.model.title],
      });
      this.model = {
        title: '',
        value: '',
      };
    },
    deleteField: function (target) {
      this.items = this.items.filter(function (item) {
        return item !== target;
      });
    },
    loadField: function () {
      this.items = [];
      for (const [key, value] of Object.entries(this.builtinFields)) {
        this.items.push({
          title: key,
          value: value,
          field: this.customFields[key],
        });
      }
      this.model = {
        title: '',
        value: '',
      };
      this.applyJson();
    },
    applyJson: function () {
      if (this.items?.length > 0) {
        let convertObj = {};
        this.items.forEach((item) => {
          let value = item.value;
          if (item.title === 'issue_watcher_user_ids') {
            value = item.value.map(user => {
              let idx = user.lastIndexOf(':');
              return user.substring(idx + 1);
            });
          }
          convertObj[item.title] = value;
        });
        this.json = JSON.stringify(convertObj);
      }
    },
    show: async function(trackerId) {
      if (trackerId) {
        this.$el.style.display = 'block';
        this.customFields = await this.getCustomFields(trackerId);
      } else {
        this.$el.style.display = 'none';
      }
    }
  },
  mounted: async function () {
    const trackerPulldown = document.getElementById(this.trackerPulldownId);
    await this.show(trackerPulldown?.value);
    this.loadField();

    trackerPulldown.addEventListener('change', (event) => {
      this.show(event.target.value);
    });
  },
  computed: {
    currentField: function () {
      const fields = this.customFields;
      const title = this.model.title;
      return fields[title];
    },
    fieldFormat: function () {
      const fields = this.customFields;
      const title = this.model.title;
      const format = fields[title]?.field_format;
      if (AVAILABLE_FORMATS.includes(format)) {
        return format;
      }
      return 'text';
    },
  },
};
</script>
