import Vue from 'vue';
import JsonGenerator from './components/JsonGenerator.vue';
import { CustomFieldPlugin } from './plugins/customFields';

const TemplateFields = function (props = {}) {
  const {
    loadSelectableFieldsPath,
    templateId,
    projectId,
    trackerPulldownId,
    base_builtin_fields,
    relativeUrlRoot,
    templateType,
  } = props;
  Vue.use(CustomFieldPlugin, {
    baseUrl: loadSelectableFieldsPath,
    templateId,
    projectId,
  });

  new Vue({
    render: (h) => h(JsonGenerator, { props })
  }).$mount('#json_generator');

  // Apply post data.
  const copyJson = document.getElementById('paste-json');
  if (copyJson) {
    copyJson.addEventListener('click', () => {
      const data = document.getElementById('builtin_fields_data_via_vue')
      if (data) {
        const text = data.innerText
        let jsonObj = JSON.parse(text)
        let convertObj = {}
        jsonObj.forEach(item => {
          let value = item.value
          if (item.title === 'issue_watcher_user_ids') {
            value = item.value.map(user => {
              let idx = user.lastIndexOf(':')
              return user.substring(idx + 1)
            })
          }
          convertObj[item.title] = value
        })
        document.getElementById(templateType + '_builtin_fields').value = JSON.stringify(convertObj)
      }
    })
  }
};

window.RedmineIssueTemplate ||= {};
window.RedmineIssueTemplate.TemplateFields = TemplateFields;
