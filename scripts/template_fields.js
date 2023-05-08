import Vue from 'vue';
import JsonGenerator from './components/JsonGenerator.vue';
import { CustomFieldPlugin } from './plugins/customFields';
import { LocalePlugin } from './plugins/locales';

const TEMPLATE_FIELDS = function (props) {
  const {
    loadSelectableFieldsPath,
    templateId,
    projectId,
    locales,
  } = props;
  Vue.use(LocalePlugin, locales);
  Vue.use(CustomFieldPlugin, {
    baseUrl: loadSelectableFieldsPath,
    templateId,
    projectId,
  });

  new Vue({
    render: (h) => h(JsonGenerator, { props })
  }).$mount('#json_generator');
};

window.TEMPLATE_FIELDS = TEMPLATE_FIELDS;
