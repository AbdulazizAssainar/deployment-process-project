# This config is equivalent to both the '.circleci/extended/orb-free.yml' and the base '.circleci/config.yml'
version: 2.1

# Orbs are reusable packages of CircleCI configuration that you may share across projects, enabling you to create encapsulated, parameterized commands, jobs, and executors that can be used across multiple projects.
# See: https://circleci.com/docs/2.0/orb-intro/
orbs:
  node: circleci/node@4.7
  eb: circleci/aws-elastic-beanstalk@2.0.1
  aws-cli: circleci/aws-cli@3.1.1


jobs:
  build:
    docker:
      # the base image can run most needed actions with orbs
      - image: "cimg/node:4.7"
    steps:
      # install node and checkout code
      - node/install:
          node-version: '4.7'         
      - checkout
      # Use root level package.json to install dependencies in the frontend app
      - run:
          name: Install Front-End Dependencies
          command: |
            echo "NODE --version" 
            echo $(node --version)
            echo "NPM --version" 
            echo $(npm --version)
            npm run frontend:install
      # TODO: Install dependencies in the the backend API          
      - run:
          name: Install API Dependencies
          command: |
            npm run api:install
      # TODO: Lint the frontend
      - run:
          name: Front-End Lint
          command: |
            npm run frontend:lint
      # TODO: Build the frontend app
      - run:
          name: Front-End Build
          command: |
            npm run frontend:build
      # TODO: Build the backend API      
      - run:
          name: API Build
          command: |
            npm run api:build
  # deploy step will run only after manual approval
  deploy:
    docker:
      - image: "cimg/base:stable"
      # more setup needed for aws, node, elastic beanstalk
    steps:
      - node/install:
          node-version: '4.7' 
      - eb/setup
      - aws-cli/setup
      - checkout
      - run:
          name: Deploy App
          # TODO: Install, build, deploy in both apps
          command: |
            npm run deploy
            echo "# TODO: Install, build, deploy in both apps"
# Invoke jobs via workflows
# See: https://circleci.com/docs/2.0/configuration-reference/#workflows
workflows:
  sample: # This is the name of the workflow, feel free to change it to better match your workflow.
    # Inside the workflow, you define the jobs you want to run.
    jobs:
      - build
      - hold:
          filters:
            branches:
              only:
                - master
          type: approval
          requires:
            - build
      - deploy:
          requires:
            - hold