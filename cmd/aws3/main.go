package main

import (
	"flag"
	"fmt"
	"os"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/credentials"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

const (
	// AWS Region
	region = "us-east-1"
)

func main() {

	awsKey := flag.String("key", "", "AWS Key")
	awsSecret := flag.String("secret", "", "AWS Secret")
	bucket := flag.String("bucket", "", "AWS Bucket")
	flag.Parse()

	sess, err := session.NewSession(&aws.Config{
		Region:                        aws.String(region),
		Credentials:                   credentials.NewStaticCredentials(*awsKey, *awsSecret, ""),
		CredentialsChainVerboseErrors: aws.Bool(true),
	},
	)
	if err != nil {
		exitErrorf("Unable to create session, %v", err)
	}

	// Create S3 service client
	svc := s3.New(sess)

	resp, err := svc.ListObjectsV2(&s3.ListObjectsV2Input{Bucket: bucket})
	if err != nil {
		exitErrorf("Unable to list items in bucket %q, %v", *bucket, err)
	}

	for _, item := range resp.Contents[0:10] {
		fmt.Println("Name:         ", *item.Key)
		fmt.Println("Last modified:", *item.LastModified)
		fmt.Println("Size:         ", *item.Size)
		fmt.Println("Storage class:", *item.StorageClass)
		fmt.Println("")
	}

}

// exitErrorf is a helper function to print an error message to stderr and
func exitErrorf(msg string, args ...interface{}) {
	fmt.Fprintf(os.Stderr, msg+"\n", args...)
	os.Exit(1)
}
