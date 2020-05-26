FROM ubuntu:14.04

ENV ANDROID_HOME /opt/android-sdk-linux
ENV PATH ${PATH}:${ANDROID_HOME}/tools/bin:${ANDROID_HOME}/platform-tools
ENV GRADLE_VERSION=6.3
ENV PATH=$PATH:"/opt/gradle/gradle-6.3/bin/"
ENV GCLOUD_SDK_CONFIG /usr/lib/google-cloud-sdk/lib/googlecloudsdk/core/config.json
ENV QT_QPA_PLATFORM offscreen
ENV LD_LIBRARY_PATH ${ANDROID_HOME}/tools/lib64:${ANDROID_HOME}/emulator/lib64:${ANDROID_HOME}/emulator/lib64/qt/lib
ENV APKINFO_TOOLS /opt/apktools

RUN dpkg --add-architecture i386 && \
    apt-get update -qq && \
    apt-get -y install wget apt-transport-https software-properties-common curl --no-install-recommends && \
    curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add - && \
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - && \
    add-apt-repository ppa:rpardini/adoptopenjdk && \
    mkdir -p /usr/share/man/man1 && \
    apt-add-repository ppa:brightbox/ruby-ng && \
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu trusty stable" && \
    echo "deb https://packages.cloud.google.com/apt cloud-sdk-`lsb_release -c -s` main" | tee -a /etc/apt/sources.list.d/google-cloud-sdk.list && \
    curl -sL https://deb.nodesource.com/setup_12.x | bash - && \
    apt-get update -qq && \
    DEBIAN_FRONTEND=noninteractive apt-get purge lxc-docker* ruby* && \
    DEBIAN_FRONTEND=noninteractive apt-cache policy docker-engine && \
    DEBIAN_FRONTEND=noninteractive apt-get -y install git mercurial rsync expect python build-essential \
                                              unzip zip tree build-essential zlib1g-dev  \
                                              libssl-dev libreadline6-dev libyaml-dev ruby2.4 ruby2.4-dev \
                                              docker-ce adoptopenjdk-8-jdk-hotspot-installer libc6-i386 lib32stdc++6 lib32gcc1 lib32ncurses5 lib32z1 \
                                              google-cloud-sdk libqt5widgets5 \
                                              nodejs --no-install-recommends && \
    ruby --version && \
    gem install rubygems-update && \
    gem install psych && \
    gem update psych && \z
    gem install bundler -v '~>1' && \
    gem install fastlane && \
    curl -fL https://github.com/docker/compose/releases/download/1.6.2/docker-compose-`uname -s`-`uname -m` > /usr/local/bin/docker-compose && \
    chmod +x /usr/local/bin/docker-compose && \
    docker-compose --version && \
    cd /opt && \
    wget -q https://dl.google.com/android/repository/sdk-tools-linux-4333796.zip -O android-sdk-tools.zip && \
    unzip -q android-sdk-tools.zip -d ${ANDROID_HOME} && \
    rm android-sdk-tools.zip && \
    cd - && \
    yes | sdkmanager  --licenses && \
    touch /root/.android/repositories.cfg && \
    sdkmanager "emulator" "tools" "platform-tools" && \
    yes | sdkmanager --update --channel=3 && \
    yes | sdkmanager \
    "platforms;android-29" \
    "platforms;android-28" \
    "build-tools;29.0.3" \
    "build-tools;28.0.3" \
    "extras;android;m2repository" \
    "extras;google;m2repository" \
    "extras;google;google_play_services" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.2" \
    "extras;m2repository;com;android;support;constraint;constraint-layout;1.0.1" \
    "add-ons;addon-google_apis-google-23" \
    "add-ons;addon-google_apis-google-22" \
    "add-ons;addon-google_apis-google-21" && \
    fastlane --version && \
    /usr/bin/gcloud config set --installation component_manager/disable_update_check true && \
    sed -i -- 's/\"disable_updater\": false/\"disable_updater\": true/g' $GCLOUD_SDK_CONFIG && \
    /usr/bin/gcloud config set --installation core/disable_usage_reporting true && \
    sed -i -- 's/\"disable_usage_reporting\": false/\"disable_usage_reporting\": true/g' $GCLOUD_SDK_CONFIG && \
    npm config set strict-ssl false && \
    npm update npm@latest && \
    npm install -g firebase-tools && \
    mkdir ${APKINFO_TOOLS} && \
    wget -q https://github.com/google/bundletool/releases/download/0.10.3/bundletool-all-0.10.3.jar -O ${APKINFO_TOOLS}/bundletool.jar && \
    cd /opt  && \
    wget -q https://dl.google.com/dl/android/maven2/com/android/tools/build/aapt2/3.5.0-5435860/aapt2-3.5.0-5435860-linux.jar -O aapt2.jar && \
    unzip -q aapt2.jar aapt2 -d ${APKINFO_TOOLS} && \
    rm aapt2.jar && \
    cd - && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
