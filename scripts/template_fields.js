import Vue from 'vue';
import JsonGenerator from './components/JsonGenerator.vue';
import { CustomFieldPlugin } from './plugins/customFields';

const TemplateFields = function (props) {
  const {
    loadSelectableFieldsPath,
    templateId,
    projectId,
  } = props;
  Vue.use(CustomFieldPlugin, {
    baseUrl: loadSelectableFieldsPath,
    templateId,
    projectId,
  });

  new Vue({
    render: (h) => h(JsonGenerator, { props })
  }).$mount('#json_generator');
};

window.RedmineIssueTemplate ||= {};
window.RedmineIssueTemplate.TemplateFields = TemplateFields;
