# concourse-qiniu-oss-resource [Concourse](https://concourse-ci.org/)

This is qiniu oss resource for [Concourse](https://concourse-ci.org/) to be able to manipulate oss on qiniu from concourse.  
这个resource type用于在concourse上通过qshell指令行工具操作七牛云oss

参考:  
[developing-a-custom-concourse-resource](https://content.pivotal.io/blog/developing-a-custom-concourse-resource)  
[Tutorials](https://github.com/concourse/concourse/wiki/Tutorials)  
[qiniu oss qshell document](https://developer.qiniu.com/kodo/tools/1302/qshell)

### build步骤:
需要一个docker注册中心,可以使用docker hub或自己搭建一个ssl安全的docker registry
```shell
docker build -t gugege/concourse-qiniu-oss-resource:0.1 -f Dockerfile .  
docker push gugege/concourse-qiniu-oss-resource:0.1  
fly -t example login --concourse-url $url  
fly -t example set-pipeline --pipeline qiniu-oss-sample --config qiniu-oss-ci.yml  --load-vars-from concourse-credentials.yml
```

### example pipeline
[qiniu-oss-ci.yml](https://github.com/gugegev5/concourse-qiniu-oss-resource/blob/master/qiniu-oss-ci.yml)

### 功能

#### put
cmds,cmd会拼成数组遍历执行  
#### get
需要单独建一个git项目,根目录放一个qiniu_cmds的文件,里面放qshell指令作为shell执行  
[qiniu_cmds demo](https://github.com/gugegev5/concourse-qiniu-oss-resource/blob/master/qiniu_cmds)


#### Parameters
```
resource_types:
- name: qiniu-oss-resource
  type: docker-image
  source:
    repository: gugege/concourse-qiniu-oss-resource
    tag: 0.1

resources:
- name: qiniu-oss
  type: qiniu-oss-resource
  source:
    qiniu_accesskey: ((qiniu_accesskey))
    qiniu_secretkey: ((qiniu_secretkey))
    qiniu_accountname: ((qiniu_accountname))
#    git_private_key: ((git_private_key))
```
```
  - put: qiniu-oss
    params:
      cmds:
      - "qshell qupload2 --src-dir=upload_src/ --bucket=front --thread-count=10 --overwrite=true --check-exists=true --check-hash=true --check-size=true --overwrite-list qiniu.overwrite.txt"

  - get: qiniu-oss
    params:
      git_url: https://github.com/gugegev5/concourse-qiniu-oss-resource.git
```

### Tips:
1. 之前的step产生的文件路径:`${task.outputs}/`
> [task-outputs](https://concourse-ci.org/tasks.html#task-outputs)
The directory will be automatically created before the task runs, and the task should ***place any artifacts it wants to export in the directory***.

```
jobs:
- name: test put
  public: true
  plan:
  - task: upload task
    config:
      platform: linux
      image_resource:
        type: docker-image
        source:
          repository: gugege/node_12_4_cnpm_rsync
          tag: '1.0'
      run:
        path: /bin/bash
        args:
        - -exc
        - |
          mkdir -p upload_src/test
          echo "testfile1" > ./upload_src/test/testfile1
          echo "testfile2" > ./upload_src/test/testfile2
          echo "testfile3" > ./upload_src/test/testfile3
          pwd
          ls -alhR .
      outputs:
      - name: upload_src
  - put: qiniu-oss
    params:
      cmds:
      - "qshell qupload2 --src-dir=upload_src/ --bucket=front --thread-count=10 --overwrite=true --check-exists=true --check-hash=true --check-size=true --overwrite-list qiniu.overwrite.txt"
```
2. tag: 1.0 在set-pipeline时会自动解析成tag: 1

### 用shell编写的resources参考list
[concourse-rsync-resource](https://github.com/mrsixw/concourse-rsync-resource)  
[rocketchat-notification-resource](https://github.com/michaellihs/rocketchat-notification-resource/blob/master/out)  
[semver-config-concourse-resource](https://github.com/brightzheng100/semver-config-concourse-resource/blob/master/in)  
[eng-concourse-resource-github-list-repos](https://github.com/coralogix/eng-concourse-resource-github-list-repos/blob/master/src/in)  
[concourse-rubygems-resource](https://github.com/troykinsella/concourse-rubygems-resource/blob/master/assets/out#L60)  
[concourse-docker-compose-resource](https://github.com/troykinsella/concourse-docker-compose-resource)  
