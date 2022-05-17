#!/bin/bash
count=5
name="node0"
dir=/root/ssh-dir
rm -rf $dir
mkdir $dir
for (( i=1; i<= $count; i++ )); do
 echo $name$i
 mkdir -p $dir/$name$i/.ssh
 ssh-keygen -b 2048 -t rsa -f $dir/$name$i/.ssh/migrate -N ""
 #ssh-keygen -f $dir/$name$i/.ssh/migrate 
 key=`cat $dir/$name$i/.ssh/migrate.pub|awk -F ' ' '{print $2}'`
 echo "ssh-rsa $key root@$name$i"   > $dir/$name$i/.ssh/migrate.pub 
 #ssh-keygen -f $dir/$name$i/.ssh/known_hosts -H
cat <<EOF >  $dir/$name$i/.bashrc
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias ssh='ssh -i /root/.ssh/migrate'
# Source global definitions
if [ -f /etc/bashrc ]; then
    . /etc/bashrc
fi
EOF
 
done

for (( i=1; i<= $count; i++ )); do
 echo $name$i
 for (( j=1; j<= $count; j++ )); do
    key=`cat $dir/$name$j/.ssh/migrate.pub|awk -F ' ' '{print $2}'`
    echo "ssh-rsa $key root@$name$j"   >>$dir/$name$i/.ssh/authorized_keys
 done
done
chmod -R 0600 $dir

echo "copy"
for (( j=1; j<= $count; j++ )); do
    scp -r $dir/$name$j/.ssh $dir/$name$j/.bashrc root@$name$j:/root 
done


# ssh root@$name$i 'echo "alias ssh=\"ssh -i /root/.ssh/migrat\"" >>/root/.bashrc'
