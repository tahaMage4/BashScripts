<?php

use Magento\Framework\App\Bootstrap;
use Magento\Framework\App\ObjectManager;
use Magento\Catalog\Model\ResourceModel\Product\CollectionFactory;
use Magento\Store\Model\StoreManagerInterface;

require '../app/bootstrap.php';

$bootstrap = Bootstrap::create(BP, $_SERVER);
$objectManager = $bootstrap->getObjectManager();

$state = $objectManager->get('Magento\Framework\App\State');
$state->setAreaCode('frontend');

$productCollectionFactory = $objectManager->get(CollectionFactory::class);
$storeManager = $objectManager->get(StoreManagerInterface::class);

// Function to get all product URLs
function getProductUrls($productCollectionFactory, $storeManager)
{
    $productUrls = [];
    $store = $storeManager->getStore();
    $baseUrl = $store->getBaseUrl();

    $products = $productCollectionFactory->create()
        ->addAttributeToSelect('url_key')
        ->addAttributeToFilter('status', ['eq' => 1]); // Only active products

    foreach ($products as $product) {
        $productUrls[] = $baseUrl . $product->getUrlKey();
    }
    return $productUrls;
}

// Function to check the status of a URL
function checkUrlStatus($url)
{
    $ch = curl_init($url);
    curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
    curl_setopt($ch, CURLOPT_NOBODY, true);
    curl_exec($ch);
    $status = curl_getinfo($ch, CURLINFO_HTTP_CODE);
    curl_close($ch);
    return $status;
}

// Get all product URLs
$productUrls = getProductUrls($productCollectionFactory, $storeManager);
$resultFile = 'result.txt';

// Clear the result file
file_put_contents($resultFile, '');

// Check each product URL
foreach ($productUrls as $url) {
    $statusCode = checkUrlStatus($url);

    if ($statusCode == 200) {
        echo "The product URL $url is accessible (Status Code: 200).\n";
    } else {
        echo "The product URL $url is not accessible (Status Code: $statusCode). Logging to $resultFile.\n";
        file_put_contents($resultFile, "$url (Status Code: $statusCode)\n", FILE_APPEND);
    }
}

echo "Check completed. See $resultFile for URLs with issues.\n";
